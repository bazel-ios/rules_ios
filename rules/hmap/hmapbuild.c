#include <getopt.h>
#include <stdarg.h>
#include <stdio.h>

#include "hmap.h"
#include "uthash.h"

static int verbose = 0;

typedef struct mapping {
    char *key;
    char *value;
    UT_hash_handle hh;
} mapping;

static void usage();
static void debug(char *format, ...);
static inline void chomp(char *s);
static void add_entry(mapping **hashmap, char *key, char *value);
static int add_mappings_from_file(mapping **hashmap, char *file);
static int add_mappings_from_headermap(mapping **hashmap, char *file);
static int add_mappings_from_headermap_file(mapping **hashmap, char *file);

static struct option longopts[] = {
    {"merge-hmaps", required_argument, NULL, 'm'},
    {"add-mappings", required_argument, NULL, 'a'},
    {"verbose", no_argument, NULL, 'v'},
    {NULL, 0, NULL, 0},
};

int main(int ac, char **av) {
    int c;
    char *extra_headermaps_file = NULL;
    char *extra_mappings_file = NULL;
    char *input_file = NULL;
    char *output_file = NULL;

    while ((c = getopt_long(ac, av, "m:a:", longopts, NULL)) != -1) {
        switch (c) {
            case 'm':
                extra_headermaps_file = strdup(optarg);
                break;
            case 'a':
                extra_mappings_file = strdup(optarg);
                break;
            case 'v':
                verbose = 1;
                break;
            default:
                usage();
        }
    }
    ac -= optind;
    av += optind;
    if (ac < 2) usage();
    input_file = av[0];
    output_file = av[1];

    // process it
    mapping *entries = NULL;

    debug("Adding inputs");
    if (add_mappings_from_file(&entries, input_file)) {
        fprintf(stderr, "Failed to add mappings from %s\n", input_file);
        exit(1);
    }

    // add extra mappings:
    if (extra_mappings_file) {
        debug("Adding mappings");
        if (add_mappings_from_file(&entries, extra_mappings_file)) {
            fprintf(stderr, "Failed to add extra mappings from '%s'\n",
                    extra_mappings_file);
            exit(1);
        }
    }

    // add extra header maps
    if (extra_headermaps_file) {
        debug("Adding header maps");
        if (add_mappings_from_headermap_file(&entries, extra_headermaps_file)) {
            fprintf(stderr, "Failed to add headermaps for file '%s'\n",
                    extra_headermaps_file);
            exit(1);
        }
    }

    debug("Writing final header map");

    mapping *m;
    unsigned numEntries = 0;
    for (m = entries; m != NULL; m = m->hh.next) {
        numEntries++;
    }
    debug("%u entries", numEntries);
    HeaderMap *hmap = hmap_new(numEntries);
    for (m = entries; m != NULL; m = m->hh.next) {
        if (hmap_addEntry(hmap, m->key, m->value)) {
            fprintf(stderr, "failed to add '%s' to hmap\n", m->key);
        }
    }
    if (hmap_save(hmap, output_file)) {
        perror(output_file);
    }
    hmap_free(hmap);
    // don't bother free'ing the hash since we are exiting anyway
    return 0;
}

static void usage() {
    fprintf(stderr,
            "hmaptool: [--merge-hmaps <file>] [--add-mappings <file>] "
            "<input_file> <output_file>\n");
    exit(1);
}

static void debug(char *format, ...) {
    if (!verbose) return;
    char *buffer = NULL;
    va_list args;
    va_start(args, format);
    vasprintf(&buffer, format, args);
    printf("%s\n", buffer);
    free(buffer);
    va_end(args);
}

static void add_entry(mapping **hashmap, char *key, char *value) {
    mapping *entry = NULL;
    HASH_FIND_STR(*hashmap, key, entry);
    if (entry) {
        // key already in the hash, verify the value
        if (strcmp(value, entry->value)) {
            fprintf(stderr,
                    "WARNING: header '%s' already in cache as '%s' ignoring "
                    "new value: '%s'\n",
                    key, entry->value, value);
        }
        return;
    }
    entry = calloc(1, sizeof(mapping));
    entry->key = key;
    entry->value = value;
    HASH_ADD_KEYPTR(hh, *hashmap, entry->key, strlen(entry->key), entry);
}

static inline void chomp(char *s) {
    unsigned len = strlen(s);
    if (s[len - 1] == '\n') s[len - 1] = '\0';
}

static int add_mappings_from_file(mapping **hashmap, char *file) {
    FILE *f = fopen(file, "r");
    if (!f) {
        perror(file);
        return 1;
    }
    // read the input file to build the initial hashmap
    ssize_t nread;
    char *line = NULL;
    size_t len;
    while ((nread = getline(&line, &len, f)) != -1) {
        chomp(line);
        if (strlen(line) == 0) continue;  // skip empty lines
        char *pipe = strchr(line, '|');
        if (!pipe) {
            fprintf(stderr, "Error parsing k|v pair in line: '%s'\n", line);
            exit(1);
        }
        *pipe = '\0';
        char *key = strdup(line);
        char *value = strdup(++pipe);
        add_entry(hashmap, key, value);
    }
    fclose(f);
    if (line) free(line);
    return 0;
}

static int add_mappings_from_headermap(mapping **hashmap, char *file) {
    int rc = 0;
    char *key, *value;
    debug("Merging in '%s'", file);
    HeaderMap *hmap = hmap_open(file, "r'");
    if (!hmap) {
        return 1;
    }
    HMAP_EACH(hmap, key, value) { add_entry(hashmap, key, value); }
    hmap_close(hmap);
    debug("'%s' Merged", file);
    return rc;
}

static int add_mappings_from_headermap_file(mapping **hashmap, char *file) {
    int rc = 0;
    FILE *f = fopen(file, "r");
    if (!f) {
        perror(file);
        return 1;
    }
    // read the input file to build the initial hashmap
    ssize_t nread;
    char *line = NULL;
    size_t len;
    while ((nread = getline(&line, &len, f)) != -1) {
        chomp(line);
        rc |= add_mappings_from_headermap(hashmap, line);
    }
    fclose(f);
    if (line) free(line);
    return rc;
}
