#include <assert.h>
#include <fcntl.h>
#include <getopt.h>
#include <libgen.h>
#include <stdarg.h>
#include <stdio.h>
#include <sys/errno.h>
#include <sys/mman.h>
#include <sys/stat.h>

#include "hmap.h"
#include "lines.h"
#include "uthash.h"

static int verbose = 0;

typedef struct mapping {
    char *key;
    char *value;
    UT_hash_handle hh;
} mapping;

static struct {
    char *name_space;
    char *output_file;
} cli_args;

static void usage();
static void debug(char *format, ...);

static inline void chomp(char *s);
static void add_entry(mapping **hashmap, char *key, char *value);
static void add_header(mapping **hashmap, char *name_space, char *header);
static void parse_args(mapping **hashmap, char **av, int ac);
static void parse_param_file(mapping **hashmap, char *file);

static struct option longopts[] = {
    {"namespace", required_argument, NULL, 'n'},
    {"output", required_argument, NULL, 'o'},
    {"verbose", no_argument, NULL, 'v'},
    {NULL, 0, NULL, 0},
};

int main(int ac, char **av) {
    cli_args.name_space = NULL;
    cli_args.output_file = NULL;
    mapping *entries = NULL;

    parse_args(&entries, av, ac);

    mapping *m;
    unsigned numEntries = 0;
    for (m = entries; m != NULL; m = m->hh.next) {
        numEntries++;
    }
    debug("Writing hmap with %u entries", numEntries);
    HeaderMap *hmap = hmap_new(numEntries);
    for (m = entries; m != NULL; m = m->hh.next) {
        if (hmap_addEntry(hmap, m->key, m->value)) {
            fprintf(stderr, "failed to add '%s' to hmap\n", m->key);
        }
    }
    if (hmap_save(hmap, cli_args.output_file)) {
        perror(cli_args.output_file);
    }
    hmap_free(hmap);
    return 0;
}

static void usage() {
    fprintf(stderr, "hmaptool: ");
    for (struct option *op = longopts; op->name; ++op) {
        fprintf(stderr, "[--%s", op->name);
        if (op->has_arg == required_argument) fprintf(stderr, " <arg>");
        fprintf(stderr, "]");
    }
    fprintf(stderr, " [<hdr>...]\n");
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

static void parse_args(mapping **entries, char **av, int ac) {
    int c;
    optind = 0;
    while ((c = getopt_long(ac, av, "n:o:", longopts, NULL)) != -1) {
        switch (c) {
            case 'n':
                cli_args.name_space = strdup(optarg);
                break;
            case 'o':
                cli_args.output_file = strdup(optarg);
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

    // all remaining arguments are the actual headers
    for (; *av; av++) {
        if (**av == '@') {
            // param file
            parse_param_file(entries, *av);
            continue;
        }
        add_header(entries, cli_args.name_space, *av);
    }
}

static void add_header(mapping **hashmap, char *name_space, char *header) {
    char *bn = strdup(basename(header));
    if (bn == NULL) {
        fprintf(stderr,
                "Failed to parse '%s': could not extract basename: %s\n",
                header, strerror(errno));
        exit(1);
    }
    add_entry(hashmap, bn, strdup(header));
    if (name_space) {
        char *key = NULL;
        asprintf(&key, "%s/%s", name_space, bn);
        if (!key) {
            perror("malloc");
            exit(1);
        }
        add_entry(hashmap, key, strdup(header));
    }
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

static void parse_param_file(mapping **hashmap, char *file) {
    assert(file[0] == '@');
    file++;  // skip @

    FILE *f = fopen(file, "r");
    if (!f) {
        perror(file);
        exit(1);
    }
    ssize_t nread;
    char *line = NULL;
    size_t len;
    char **av = NULL;
    while ((nread = getline(&line, &len, f)) != -1) {
        chomp(line);
        av = addLine(av, line);
        line = NULL;
    }
    av = addLine(av, NULL);
    fclose(f);
    parse_args(hashmap, av, nLines(av));
}
