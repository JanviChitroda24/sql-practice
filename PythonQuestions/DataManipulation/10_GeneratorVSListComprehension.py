# Generators vs List Comprehensions — explain the difference, then show it.

# Here's the setup. Say you have a 10GB log file and you want to extract all error messages:

# python
# List comprehension — loads everything into memory
errors = [parse_error(line) for line in open("huge_log.txt") if "ERROR" in line]

# Your task:
# 1. Explain what's wrong with this for a 10GB file
# 2. Rewrite it as a generator
# 3. Explain when you'd use each in a data pipeline

######################################################
######################################################
######################################################
######################################################
#1. Explain what's wrong with this for a 10GB file
# Reading the file itself is fine. 
#     open() in Python returns an iterator that reads one line at a time, 
#         so even a 10GB file doesn't get loaded into memory all at once. That part is efficient.

# The problem is the list comprehension wrapping it. 
#     The square brackets force Python to evaluate 
#         every matching line and collect all the results into a list before anything downstream can use them. 
#         So if there are millions of error lines in that 10GB file, we end up holding all of those parsed errors in memory at once. 
#         That could be gigabytes of data, causing the process to slow down or crash with an out-of-memory error.

# The fix is to use a generator instead. 
#     Replace the square brackets with parentheses or use yield. 
#     A generator produces one result at a time, the consumer processes it and discards it, 
#     and only then the next result is produced. Memory stays flat regardless of file size.



######################################################
######################################################
######################################################
######################################################
# 2. Rewrite it as a generator
# List comprehension — loads everything into memory
def parse_error(line):
    return line
errors = [parse_error(line) for line in open("huge_log.txt") if "ERROR" in line]

# Generator
# using ()
def parse_error(line):
    return line
errors = ( parse_error(line) for line in open("huge_log.txt") if 'ERROR' in line )
for error in errors:
    print(error)  # or write to database, send to API, etc.

# using yield
def parse_error(line):
    return line

def yield_error(filepath):
    for line in open(filepath):
        if 'ERROR' in line:
            yield parse_error(line)

for error in yield_error("huge_log.txt"):
    print(error)


######################################################
######################################################
######################################################
######################################################
# 3. Explain when you'd use each in a data pipeline
# Use a generator when:
# You're processing data that flows in one direction. 
# Read from a source, transform, write to a destination. 
# You don't need to go back and look at previous records. 
# Examples: 
#     reading a log file and writing errors to a database, 
#     streaming Kafka messages and transforming them one at a time, 
#     reading a CSV and inserting rows into a table, 
#     ETL pipelines where each record is independent.

# Use a list when:
# You need to access the data more than once or need the whole picture before making decisions. 
# Examples: 
#     you need to sort the data (sorting requires seeing all values), 
#     you need to compute something that depends on all records first 
#         (like finding the max, then comparing each record to it), 
#     you need to iterate twice (once to count, once to process), 
#     you need random access like data[5] or data[-1].