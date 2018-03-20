import zipfile
from zipfile import ZipFile
import os

def fuse(samples, output, target=""):

    if target == "":
        target="./working/fused.fastq"

    combination_file = open(target,mode='w')

    for sample_file in samples:

        output.write( "Processing " + line)

        file_count += 1

        if sample_file.split(".")[-1] == "gz":

            with ZipFile(sample_file,'w') as zipped_file:

                decompressed = zipped_file.open()
                for line in decompressed:
                    combination_file.write(line)
                    line_count += 1


                output.write( "Finished consolidating " + sample_file)

        elif sample_file.split(".")[-1] == "fastq":

            for line in open(sample_file):
                combination_file.write(line)
                line_count +=1

            output.write( "Finished consolidating " + sample_file)

    output.write("Done with all files, combination is:")

    output.write( str(line_count) + " lines")
    output.write( "from " + str(file_count) + " files")

    return target

def main():
    fuse(sys.argv[1:],sys.stdout)

if __name__ == '__main__':
    main()
