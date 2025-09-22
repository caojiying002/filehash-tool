#ifndef FILEHASH_H
#define FILEHASH_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <openssl/md5.h>
#include <openssl/sha.h>

#define MAX_PATH_LENGTH 1024
#define BUFFER_SIZE 8192

typedef enum {
    HASH_MD5,
    HASH_SHA1,
    HASH_SHA256
} hash_type_t;

typedef struct {
    hash_type_t type;
    char *filename;
    unsigned char hash[SHA256_DIGEST_LENGTH];
    size_t hash_length;
} file_hash_t;

int calculate_file_hash(const char *filename, hash_type_t type, unsigned char *hash_output);
void print_hash(const unsigned char *hash, size_t length, const char *filename, hash_type_t type);
const char* get_hash_name(hash_type_t type);
void print_usage(const char *program_name);
int is_valid_file(const char *filename);

#endif