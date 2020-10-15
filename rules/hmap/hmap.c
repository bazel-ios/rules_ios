#include "hmap.h"

#include <assert.h>
#include <ctype.h>
#include <fcntl.h>
#include <libgen.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/errno.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>

// Mac OS X doesn't have byteswap.h
#if defined(__APPLE__)
#include <libkern/OSByteOrder.h>
#define bswap_16(x) OSSwapInt16(x)
#define bswap_32(x) OSSwapInt32(x)
#define bswap_64(x) OSSwapInt64(x)
#endif

#define max(a, b)               \
    ({                          \
        __typeof__(a) _a = (a); \
        __typeof__(b) _b = (b); \
        _a > _b ? _a : _b;      \
    })

enum {
    HMAP_HeaderMagicNumber = ('h' << 24) | ('m' << 16) | ('a' << 8) | 'p',
    HMAP_HeaderVersion = 1,
    HMAP_EmptyBucketKey = 0
};

typedef struct HMapBucket {
    uint32_t Key;     // Offset (into strings) of key.
    uint32_t Prefix;  // Offset (into strings) of value prefix.
    uint32_t Suffix;  // Offset (into strings) of value suffix.
} HMapBucket;

typedef struct HMapHeader {
    uint32_t Magic;           // Magic word, also indicates byte order.
    uint16_t Version;         // Version number -- currently 1.
    uint16_t Reserved;        // Reserved for future use - zero for now.
    uint32_t StringsOffset;   // Offset to start of string pool.
    uint32_t NumEntries;      // Number of entries in the string table.
    uint32_t NumBuckets;      // Number of buckets (always a power of 2).
    uint32_t MaxValueLength;  // Length of longest result path (excluding nul).
                              // An array of 'NumBuckets' HMapBucket objects
                              // follows this header. Strings follow the
                              // buckets, at StringsOffset.
} HMapHeader;

typedef struct HeaderMap {
    char* data;                      // storage for the header map
    size_t size;                     // size of data storage
    int needsSwap;                   // endianness
    uint32_t stringsTableNextEntry;  // offset of where the next entry goes
} HeaderMap;

#define HEADER(hmap) ((HMapHeader*)hmap->data)
#define BUCKET_TABLE(hmap) ((HMapBucket*)(hmap->data + sizeof(HMapHeader)))

static HMapBucket getBucket(HeaderMap* hmap, unsigned int bucketNumber);
static HMapBucket* findBucketForKey(HeaderMap* hmap, char* key);
static HMapBucket* findEmptyBucket(HeaderMap* hmap, char* key);
static char* getStringFromTable(HeaderMap* hmap, unsigned int tblIndex);
static inline int isPowerOf2(uint32_t v);
static inline int nextPowerOf2(uint32_t v);
static inline unsigned addStringToTable(HeaderMap* hmap, char* str);
static inline unsigned hmapKey(char* str);
static int checkHeader(HeaderMap*);
static void dumpBuckets(HMapBucket* table, unsigned size);
static void dumpHeader(HMapHeader* header);
static void dumpStringsTable(char* start, unsigned num, char* end);

// PUBLIC API

HeaderMap* hmap_open(char* path, char* mode) {
    int oflags = O_RDONLY;
    int mprot = PROT_READ;
    if (strstr(mode, "w")) {
        oflags = O_RDWR;
        mprot |= PROT_WRITE;
    }
    int fd = open(path, oflags, 0);
    if (fd < 0) {
        fprintf(stderr, "open(%s): %s\n", path, strerror(errno));
        return NULL;
    }
    struct stat st;
    if (fstat(fd, &st) != 0) {
        fprintf(stderr, "fstat(%s): %s\n", path, strerror(errno));
        close(fd);
        return NULL;
    }
    char* data = mmap(0, st.st_size, mprot, MAP_SHARED, fd, 0);
    if (data == MAP_FAILED) {
        fprintf(stderr, "mmap(%s): %s\n", path, strerror(errno));
        close(fd);
        return NULL;
    }
    // POSIX says it's safe to close the file descriptor
    // http://pubs.opengroup.org/onlinepubs/7908799/xsh/mmap.html
    close(fd);
    HeaderMap* hmap = (HeaderMap*)calloc(1, sizeof(HeaderMap));
    hmap->data = data;
    hmap->size = st.st_size;
    hmap->stringsTableNextEntry = hmap->size + 1;
    if (!checkHeader(hmap)) {
        fprintf(stderr, "invalid hmap header\n");
        hmap_close(hmap);
        return NULL;
    }
    return hmap;
}

HeaderMap* hmap_new(unsigned numKeys) {
    HeaderMap* hmap = (HeaderMap*)calloc(1, sizeof(HeaderMap));
    unsigned numBuckets = nextPowerOf2(numKeys * 3);  // default is 1/3d full
    unsigned stringOffset =
        sizeof(HMapHeader) + numBuckets * sizeof(HMapBucket);
    hmap->size = stringOffset + 1;
    hmap->stringsTableNextEntry = stringOffset + 1;
    hmap->data = calloc(1, hmap->size);
    HMapHeader* header = (HMapHeader*)hmap->data;
    // fill in all the boring fields
    header->Magic = HMAP_HeaderMagicNumber;
    header->Version = HMAP_HeaderVersion;
    header->Reserved = 0;
    header->MaxValueLength = 0;
    header->NumBuckets = numBuckets;
    header->NumEntries = 0;
    header->StringsOffset = stringOffset;
    return hmap;
}

int hmap_addEntry(HeaderMap* hmap, char* key, char* value) {
    char* prefix;
    asprintf(&prefix, "%s/", dirname(value));
    char* suffix = basename(value);

    uint32_t key_idx = addStringToTable(hmap, key);
    uint32_t prefix_idx = addStringToTable(hmap, prefix);
    uint32_t suffix_idx = addStringToTable(hmap, suffix);

    HMapBucket* bucket = findEmptyBucket(hmap, key);
    if (!bucket) {
        // table full
        return 1;
    }
    bucket->Key = key_idx;
    bucket->Prefix = prefix_idx;
    bucket->Suffix = suffix_idx;

    HEADER(hmap)->MaxValueLength =
        max(HEADER(hmap)->MaxValueLength, strlen(value));
    HEADER(hmap)->NumEntries += 3;  // key, prefix, suffix
    free(prefix);
    return 0;
}

int hmap_findEntry(HeaderMap* hmap, char* key, char** value) {
    HMapBucket* bucket = findBucketForKey(hmap, key);
    if (!bucket) {
        *value = NULL;
        return 1;
    }
    char* prefix = getStringFromTable(hmap, bucket->Prefix);
    char* suffix = getStringFromTable(hmap, bucket->Suffix);
    asprintf(value, "%s%s", prefix, suffix);
    return 0;
}

void hmap_free(HeaderMap* hmap) {
    free(hmap->data);
    free(hmap);
}

void hmap_close(HeaderMap* hmap) {
    munmap(hmap->data, hmap->size);
    free(hmap);
}

int hmap_save(HeaderMap* hmap, char* path) {
    int fd = open(path, O_CREAT | O_WRONLY, 0644);
    if (fd < 0) {
        perror(path);
        return 1;
    }
    int rc = 0;
    if (write(fd, hmap->data, hmap->stringsTableNextEntry) !=
        hmap->stringsTableNextEntry) {
        perror(path);
        rc = 1;
    }
    close(fd);
    return rc;
}

void hmap_dump(HeaderMap* hmap) {
    printf("Header:\n");
    dumpHeader(HEADER(hmap));
    printf("Buckets:\n");
    dumpBuckets((HMapBucket*)(hmap->data + sizeof(HMapHeader)),
                HEADER(hmap)->NumBuckets);
    printf("StringsTable:\n");
    dumpStringsTable((hmap->data + HEADER(hmap)->StringsOffset),
                     HEADER(hmap)->NumEntries, hmap->data + hmap->size);
    printf("Entries:\n");
    for (unsigned int i = 0; i < HEADER(hmap)->NumBuckets; ++i) {
        HMapBucket b = getBucket(hmap, i);
        if (b.Key == HMAP_EmptyBucketKey) continue;
        char* key = getStringFromTable(hmap, b.Key);
        char* prefix = getStringFromTable(hmap, b.Prefix);
        char* suffix = getStringFromTable(hmap, b.Suffix);
        printf("[%u] '%s' -> '%s' '%s'\n", i, key, prefix, suffix);
    }
}

// utility function helpful for iterating over a header map. Not
// intended to be called directly but through the macro HMAP_EACH()
int hmap_getidx(HeaderMap* hmap, unsigned start, char** key, char** val) {
    if (start >= HEADER(hmap)->NumBuckets) return 0;
    for (unsigned i = start; i < HEADER(hmap)->NumBuckets; ++i) {
        HMapBucket b = getBucket(hmap, i);
        if (b.Key == HMAP_EmptyBucketKey) continue;
        *key = strdup(getStringFromTable(hmap, b.Key));
        asprintf(val, "%s%s", getStringFromTable(hmap, b.Prefix),
                 getStringFromTable(hmap, b.Suffix));
        return i + 1;
    }
    return 0;
}

// Internal functions

static inline unsigned hmapKey(char* str) {
    unsigned result = 0;
    char* end = str + strlen(str);
    for (char* c = str; c < end; c++) result += tolower(*c) * 13;
    return result;
}

static inline int isPowerOf2(uint32_t v) { return v && !(v & (v - 1)); }
static inline int nextPowerOf2(uint32_t v) {
    if (isPowerOf2(v)) return v;
    unsigned n = 0;
    while (v != 0) {
        v >>= 1;
        n++;
    }
    return 1 << n;
}

static void dumpHeader(HMapHeader* header) {
    uint32_t magic = header->Magic;
    printf("Magic: %c%c%c%c\n", magic >> 24, magic >> 16 & 0xff,
           magic >> 8 & 0xff, magic & 0xff);
    printf("Version: %u\n", header->Version);
    printf("Reserved: %u\n", header->Reserved);
    printf("StringsOffset: %u\n", header->StringsOffset);
    printf("NumEntries: %u\n", header->NumEntries);
    printf("NumBuckets: %u\n", header->NumBuckets);
    printf("MaxValueLength: %u\n", header->MaxValueLength);
}

static void dumpBuckets(HMapBucket* table, unsigned size) {
    for (unsigned i = 0; i < size; ++i) {
        if (table[i].Key == HMAP_EmptyBucketKey) {
            printf("%u: empty\n", i);
        } else {
            printf("%u: %u %u %u\n", i, table[i].Key, table[i].Prefix,
                   table[i].Suffix);
        }
    }
}

static void dumpStringsTable(char* start, unsigned num, char* end) {
    unsigned i = 0;
    unsigned offset = 0;
    while (i < num + 1) {
        printf("%u: %s\n", offset, start);
        unsigned len = strlen(start) + 1;
        start += len;
        offset += len;

        if (start > end) {
            fprintf(stderr, "StringsTable Overrun!\n");
            break;
        }
        i++;
    }
}

static uint32_t maybe_bswap32(HeaderMap* hmap, uint32_t v) {
    if (hmap->needsSwap) {
        return bswap_32(v);
    }
    return v;
}

// Checks that the header is a valid header map header.
static int checkHeader(HeaderMap* hmap) {
    if (hmap->size <= sizeof(HMapHeader)) {
        return 0;
    }
    HMapHeader* header = (HMapHeader*)hmap->data;
    if (header->Magic == HMAP_HeaderMagicNumber &&
        header->Version == HMAP_HeaderVersion) {
        hmap->needsSwap = 0;
    } else if (header->Magic == bswap_32(HMAP_HeaderMagicNumber) &&
               header->Version == bswap_16(HMAP_HeaderVersion)) {
        hmap->needsSwap = 1;
    } else {
        // not a header map
        return 0;
    }
    // Not sure why this is, it was in llvm's implementation
    if (header->Reserved != 0) {
        return 0;
    }
    // check number of buckets, it should be a power of two and there
    // should be enough space in the file for all of them.
    uint32_t numBuckets = maybe_bswap32(hmap, header->NumBuckets);
    if (!isPowerOf2(numBuckets)) {
        return 0;
    }
    if (hmap->size < sizeof(HMapHeader) + sizeof(HMapBucket) * numBuckets) {
        return 0;
    }
    return 1;
}

// Get bucket from HeaderMap data structure
static HMapBucket getBucket(HeaderMap* hmap, unsigned int bucketNumber) {
    assert(hmap);
    assert(hmap->size >=
           sizeof(HMapHeader) + sizeof(HMapBucket) * bucketNumber);
    HMapBucket result;
    result.Key = HMAP_EmptyBucketKey;
    HMapBucket* bucketArray = BUCKET_TABLE(hmap);
    HMapBucket* bucket = bucketArray + bucketNumber;
    // load values, byte-swapping as needed
    result.Key = maybe_bswap32(hmap, bucket->Key);
    result.Prefix = maybe_bswap32(hmap, bucket->Prefix);
    result.Suffix = maybe_bswap32(hmap, bucket->Suffix);
    return result;
}

static HMapBucket* findEmptyBucket(HeaderMap* hmap, char* key) {
    unsigned hkey = hmapKey(key);
    HMapBucket* table = BUCKET_TABLE(hmap);
    uint32_t numBuckets = HEADER(hmap)->NumBuckets;
    assert(numBuckets);
    unsigned i;
    for (i = 0; i < numBuckets; ++i) {
        unsigned idx = (hkey + i) % numBuckets;
        if (table[idx].Key == HMAP_EmptyBucketKey) {
            return &(table[idx]);
        }
    }
    // we couldn't find an empty bucket
    return NULL;
}

static HMapBucket* findBucketForKey(HeaderMap* hmap, char* key) {
    unsigned hkey = hmapKey(key);
    HMapBucket* table = BUCKET_TABLE(hmap);
    uint32_t numBuckets = HEADER(hmap)->NumBuckets;
    unsigned i;
    for (i = 0; i < numBuckets; ++i) {
        unsigned idx = (hkey + i) % numBuckets;
        if (table[idx].Key == HMAP_EmptyBucketKey) {
            // didn't find it
            return NULL;
        }
        char* bucketKey = getStringFromTable(hmap, table[idx].Key);
        if (!bucketKey) {
            continue;
        }
        if (strcmp(bucketKey, key)) {
            continue;
        }
        // match
        return &(table[idx]);
    }
    return NULL;
}

static char* getStringFromTable(HeaderMap* hmap, unsigned int tblIndex) {
    tblIndex += HEADER(hmap)->StringsOffset;
    if (tblIndex >= hmap->size) {
        return NULL;
    }
    char* data = hmap->data + tblIndex;
    unsigned maxLen = hmap->size - tblIndex;
    unsigned len = strnlen(data, maxLen);
    // make sure it's null terminated
    if (len == maxLen && data[len]) {
        fprintf(stderr, "Invalid string at %u. Not NULL terminated\n",
                tblIndex);
        assert(0);
    }
    return data;
}

static inline unsigned addStringToTable(HeaderMap* hmap, char* str) {
    unsigned idx = hmap->stringsTableNextEntry;
    unsigned len = strlen(str);
    if (idx + len + 1 >= hmap->size) {
        while (idx + len + 1 >= hmap->size) { hmap->size *= 2; }
        hmap->data = reallocf(hmap->data, hmap->size);
        assert(hmap->data);
    }
    memcpy(hmap->data + idx, str, len + 1);
    hmap->stringsTableNextEntry += len + 1;
    hmap->data[hmap->stringsTableNextEntry] = '\0';

    return idx - HEADER(hmap)->StringsOffset;
}
