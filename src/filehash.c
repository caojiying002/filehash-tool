#include "filehash.h"

int calculate_file_hash(const char *filename, hash_type_t type, unsigned char *hash_output) {
    FILE *file = fopen(filename, "rb");
    if (!file) {
        fprintf(stderr, "Error: Cannot open file '%s'\n", filename);
        return -1;
    }

    unsigned char buffer[BUFFER_SIZE];
    size_t bytes_read;

    switch (type) {
        case HASH_MD5: {
            MD5_CTX ctx;
            MD5_Init(&ctx);
            while ((bytes_read = fread(buffer, 1, BUFFER_SIZE, file)) > 0) {
                MD5_Update(&ctx, buffer, bytes_read);
            }
            MD5_Final(hash_output, &ctx);
            break;
        }
        case HASH_SHA1: {
            SHA_CTX ctx;
            SHA1_Init(&ctx);
            while ((bytes_read = fread(buffer, 1, BUFFER_SIZE, file)) > 0) {
                SHA1_Update(&ctx, buffer, bytes_read);
            }
            SHA1_Final(hash_output, &ctx);
            break;
        }
        case HASH_SHA256: {
            SHA256_CTX ctx;
            SHA256_Init(&ctx);
            while ((bytes_read = fread(buffer, 1, BUFFER_SIZE, file)) > 0) {
                SHA256_Update(&ctx, buffer, bytes_read);
            }
            SHA256_Final(hash_output, &ctx);
            break;
        }
        default:
            fclose(file);
            return -1;
    }

    fclose(file);
    return 0;
}

void print_hash(const unsigned char *hash, size_t length, const char *filename, hash_type_t type) {
    printf("%s (", get_hash_name(type));
    for (size_t i = 0; i < length; i++) {
        printf("%02x", hash[i]);
    }
    printf(") = %s\n", filename);
}

const char* get_hash_name(hash_type_t type) {
    switch (type) {
        case HASH_MD5: return "MD5";
        case HASH_SHA1: return "SHA1";
        case HASH_SHA256: return "SHA256";
        default: return "UNKNOWN";
    }
}

int is_valid_file(const char *filename) {
    struct stat path_stat;
    if (stat(filename, &path_stat) != 0) {
        return 0;
    }

    if (S_ISDIR(path_stat.st_mode)) {
        fprintf(stderr, "Error: '%s' is a directory, not a file\n", filename);
        return 0;
    }

    if (!S_ISREG(path_stat.st_mode)) {
        fprintf(stderr, "Error: '%s' is not a regular file\n", filename);
        return 0;
    }

    return 1;
}

void print_usage(const char *program_name) {
    printf("Usage: %s [OPTIONS] FILE...\n", program_name);
    printf("Calculate hash values for files\n\n");
    printf("Options:\n");
    printf("  -m, --md5      Calculate MD5 hash (default)\n");
    printf("  -s, --sha1     Calculate SHA1 hash\n");
    printf("  -S, --sha256   Calculate SHA256 hash\n");
    printf("  -a, --all      Calculate all hash types\n");
    printf("  -h, --help     Show this help message\n");
    printf("  -v, --version  Show version information\n\n");
    printf("Examples:\n");
    printf("  %s file.txt                # Calculate MD5 hash\n", program_name);
    printf("  %s -s file.txt             # Calculate SHA1 hash\n", program_name);
    printf("  %s -S file.txt             # Calculate SHA256 hash\n", program_name);
    printf("  %s -a file.txt             # Calculate all hash types\n", program_name);
    printf("  %s *.txt                   # Calculate MD5 for all .txt files\n", program_name);
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        print_usage(argv[0]);
        return 1;
    }

    hash_type_t hash_type = HASH_MD5;
    int calculate_all = 0;
    int file_start_index = 1;

    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-h") == 0 || strcmp(argv[i], "--help") == 0) {
            print_usage(argv[0]);
            return 0;
        } else if (strcmp(argv[i], "-v") == 0 || strcmp(argv[i], "--version") == 0) {
            printf("filehash 1.0.0\n");
            printf("A simple file hash calculator supporting MD5, SHA1, and SHA256\n");
            return 0;
        } else if (strcmp(argv[i], "-m") == 0 || strcmp(argv[i], "--md5") == 0) {
            hash_type = HASH_MD5;
            file_start_index = i + 1;
        } else if (strcmp(argv[i], "-s") == 0 || strcmp(argv[i], "--sha1") == 0) {
            hash_type = HASH_SHA1;
            file_start_index = i + 1;
        } else if (strcmp(argv[i], "-S") == 0 || strcmp(argv[i], "--sha256") == 0) {
            hash_type = HASH_SHA256;
            file_start_index = i + 1;
        } else if (strcmp(argv[i], "-a") == 0 || strcmp(argv[i], "--all") == 0) {
            calculate_all = 1;
            file_start_index = i + 1;
        } else {
            break;
        }
    }

    if (file_start_index >= argc) {
        fprintf(stderr, "Error: No files specified\n");
        print_usage(argv[0]);
        return 1;
    }

    int exit_code = 0;

    for (int i = file_start_index; i < argc; i++) {
        const char *filename = argv[i];

        if (!is_valid_file(filename)) {
            fprintf(stderr, "Error: Cannot access file '%s'\n", filename);
            exit_code = 1;
            continue;
        }

        if (calculate_all) {
            hash_type_t types[] = {HASH_MD5, HASH_SHA1, HASH_SHA256};
            size_t lengths[] = {MD5_DIGEST_LENGTH, SHA_DIGEST_LENGTH, SHA256_DIGEST_LENGTH};

            for (int j = 0; j < 3; j++) {
                unsigned char hash[SHA256_DIGEST_LENGTH];
                if (calculate_file_hash(filename, types[j], hash) == 0) {
                    print_hash(hash, lengths[j], filename, types[j]);
                } else {
                    exit_code = 1;
                }
            }
        } else {
            unsigned char hash[SHA256_DIGEST_LENGTH];
            size_t hash_length;

            switch (hash_type) {
                case HASH_MD5: hash_length = MD5_DIGEST_LENGTH; break;
                case HASH_SHA1: hash_length = SHA_DIGEST_LENGTH; break;
                case HASH_SHA256: hash_length = SHA256_DIGEST_LENGTH; break;
                default: hash_length = MD5_DIGEST_LENGTH; break;
            }

            if (calculate_file_hash(filename, hash_type, hash) == 0) {
                print_hash(hash, hash_length, filename, hash_type);
            } else {
                exit_code = 1;
            }
        }
    }

    return exit_code;
}