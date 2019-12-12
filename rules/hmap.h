#ifndef _HMAP_H
#define _HMAP_H

typedef struct HeaderMap HeaderMap;

#define HMAP_EACH(hmap, key, value) \
    for (unsigned __idx = 0;        \
         (__idx = hmap_getidx(hmap, __idx, &(key), &(value)));)

HeaderMap* hmap_open(char* path, char* mode);
void hmap_close(HeaderMap*);

HeaderMap* hmap_new(unsigned size);
void hmap_free(HeaderMap*);

int hmap_save(HeaderMap* hmap, char* path);

int hmap_addEntry(HeaderMap* hmap, char* key, char* value);
int hmap_findEntry(HeaderMap* hmap, char* key, char** value);
int hmap_getidx(HeaderMap* hmap, unsigned start, char** key, char** val);
void hmap_dump(HeaderMap* hmap);

#endif /* _HMAP_H */
