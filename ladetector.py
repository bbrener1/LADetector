#!/usr/bin/env python
import zipfile
from zipfile import ZipFile
import sys
import os
import subprocess

def main():

    argument_set = set(["-l","-lads","-d","-dams","-o","-output","-environment","-v","-verbose","-p","-processors","-sn","-sample_name"])

    given_set = set(sys.argv)
    if ("-l" not in given_set and "-lad" not in given_set) or ("-d" not in given_set and "-dams" not in given_set) or ("-sn" not in given_set and "-sample_name" not in given_set):
        print "Error: -sn, -l and -d are mandatory arguments"
        return 1

    arg_index = 0

    output = sys.stdout

    def lads(lad_file, read, lad_file_list=[]):
        if not read:
            lad_file_list.append(lad_file)
        return lad_file_list

    def dams(dam_file, read, dam_file_list=[]):
        if not read:
            dam_file_list.append(dam_file)
        return dam_file_list

    def out_dir(new_out, read, out_dir=["./output/"]):
        if not read:
            out_dir[0] = new_out
        return out_dir[0]

    def environment(new_env, read, environment = ["./support/"]):
        if not read:
            environment[0] = new_env
        return environment[0]

    def verbose(_,read,default = [True,]):
        if not read:
            local[0] = False
            output = os.devnull
        return default[0]

    def working(new_working, read, working = ["./working/",]):
        if not read:
            working[0] = new_working
        return working[0]

    def processors(number,read,default=[1,]):
        if not read:
            default[0] = number
        return default[0]

    def sample_name(name,read,default=["sample",]):
        if not read:
            default[0] = name
        return default[0]

    argument_match = {
        "-l" : lads,
        "-lads" : lads,
        "-d" : dams,
        "-dams" : dams,
        "-o" : out_dir,
        "-output": out_dir,
        "-sr": verbose,
        "-suppress_reporting": verbose,
        "-w": working,
        "-working_dir": working,
        "-p": processors,
        "-processors": processors,
        "-sn": sample_name,
        "-sample_name": sample_name,

    }

    current_argument = ""
    for i in range(1,len(sys.argv)):
        if sys.argv[i] in argument_set:
            current_argument = sys.argv[i]
        else:
            argument_match[current_argument](sys.argv[i],False)

    print sample_name("",True)
    print lads("",True)
    print dams("",True)
    print out_dir("",True)
    print environment("",True)
    print verbose("", True)
    print processors("",True)

    # raw_input(prompt="About to fuse, proceed?")

    fused_lads = fuse(lads("",True),output,working("",True)+sample_name("",True) + ".lmnb.fused.fastq")
    fused_dams = fuse(dams("",True),output,working("",True)+sample_name("",True) + ".dam.fused.fastq")

    pre_normalization_command = []
    pre_normalization_command.append("./scripts/pre-normalization-scoring.sh")
    pre_normalization_command.extend(["--input",fused_dams])
    pre_normalization_command.extend(["--scripts","./scripts/"])
    pre_normalization_command.extend(["--build","./data/GCA_000001405.15_GRCh38_no_alt_analysis_set"])
    pre_normalization_command.extend(["--bins","./data/DpnIIbins_hg38.bed"])
    pre_normalization_command.extend(["--slurm",str(processors("",True))])

    # raw_input(prompt="About to pre-score dam, proceed?")



    output.write("Attempting to pre-score DAM\n")
    output.write("Command is: " + " ".join(pre_normalization_command))

    if subprocess.call(pre_normalization_command,stdout=output) == 0:
        output.write("DAM prepped successfully.\n")
    else:
        raise ValueError("DAM pre-scoring returned an error code")

    # raw_input(prompt="About to pre-score lmnb, proceed?")

    pre_normalization_command = []
    pre_normalization_command.append("./scripts/pre-normalization-scoring.sh")
    pre_normalization_command.extend(["--input",fused_lads])
    pre_normalization_command.extend(["--scripts","./scripts/"])
    pre_normalization_command.extend(["--build","./data/GCA_000001405.15_GRCh38_no_alt_analysis_set"])
    pre_normalization_command.extend(["--bins","./data/DpnIIbins_hg38.bed"])
    pre_normalization_command.extend(["--slurm",str(processors("",True))])


    output.write("Attempting to pre-score LmnB\n")
    if subprocess.call(pre_normalization_command ,stdout=output) == 0:
        output.write("LmnB prepped successfully\n")
    else:
        raise ValueError("LmnB pre-scoring returned an error code")

    scoring_command = []
    scoring_command.extend(["perl","./scripts/Normalization.pl"])
    scoring_command.extend([working("",True) + sample_name("",True) + ".dam.preNormalization.score"])
    scoring_command.extend([working("",True) + sample_name("",True) + ".lmnb.preNormalization.score"])
    scoring_command.extend([working("",True) + sample_name("",True) + ".lmnb.mappedReadCounts"])
    scoring_command.extend([working("",True) + sample_name("",True) + ".lmnb.mappedReadCounts"])
    scoring_command.extend([working("",True) + sample_name("",True) + ".normalized"])

    output.write("Scoring command is ")
    output.write(scoring_command + "\n")

    # raw_input(prompt="About to normalize, proceed?")

    output.write("Attempting to normalize\n")
    if subprocess.call(scoring_command) == 0:
        output.write("Normalization successful\n")
    else:
        raise ValueError("Failed to normalize successfully")


def fuse(samples, output, target=""):

    if target == "":
        target="./working/fused.fastq"

    combination_file = open(target,mode='w')

    file_count = 0
    line_count = 0

    for sample_file in samples:

        output.write( "Processing " + sample_file + "\n")

        file_count += 1

        if sample_file.split(".")[-1] == "gz":

            with ZipFile(sample_file,'w') as zipped_file:

                decompressed = zipped_file.open()
                for line in decompressed:
                    combination_file.write(line)
                    line_count += 1


                output.write( "Finished consolidating " + sample_file + "\n")

        elif sample_file.split(".")[-1] == "fastq":

            for line in open(sample_file):
                combination_file.write(line)
                line_count +=1

            output.write( "Finished consolidating " + sample_file + "\n")

    output.write("Done with all files, combination is: ")

    output.write( str(line_count) + " lines ")
    output.write( "from " + str(file_count) + " files\n")

    return target


if __name__ == '__main__':
    main()
