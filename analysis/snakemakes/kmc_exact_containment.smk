import os
import snakemake.io
import glob


FASTQ_DIR="/home/mhussien/pag/exact_kmc/raw_data"
OUTPUT_DIR="/home/mhussien/pag/exact_kmc"

SAMPLES, = glob_wildcards(FASTQ_DIR + "/{sample}_1.fastq.gz")

runs_1 = ["ERR2241629","ERR2241630","ERR2241633","ERR2241636","ERR2241638","ERR2241640","ERR2241642","ERR2241644","ERR2241646","ERR2241648","ERR2241681","ERR2241685","ERR2241700","ERR2241766","ERR2241789","ERR2241792","ERR2241793","ERR2241797","ERR2241800","ERR2241804","ERR2241810","ERR2241811","ERR2241812","ERR2241813","ERR2241814","ERR2241827","ERR2241829","ERR2241830","ERR2241833","ERR2241835","ERR2241836","ERR2241837","ERR2241838","ERR2241839","ERR2241840","ERR2241841","ERR2241867","ERR2241868","ERR2241869","ERR2241870","ERR2241871","ERR2241872","ERR2241873","ERR2241874","ERR2241875","ERR2241876","ERR2241877","ERR2241926","ERR2241973","ERR2241974","ERR2241975","ERR2241976"]
runs_2 = ["ERR2245443","ERR2245444","ERR2245445","ERR2245446","ERR2245447","ERR2245448","ERR2245449","ERR2245450","ERR2245451","ERR2245452","ERR2245453","ERR2245454","ERR2245455","ERR2245456","ERR2245457","ERR2245458","ERR2245459","ERR2245460","ERR2245461","ERR2245462","ERR2245463","ERR2245464","ERR2245465","ERR2245466","ERR2245467","ERR2245468","ERR2245469","ERR2245470","ERR2245471","ERR2245472","ERR2245473","ERR2245474","ERR2245475","ERR2245476","ERR2245477","ERR2245478","ERR2245479","ERR2245480","ERR2245481","ERR2245482","ERR2245483","ERR2245484","ERR2245485","ERR2245486","ERR2245487","ERR2245488","ERR2245489","ERR2245490","ERR2245491","ERR2245492","ERR2245493","ERR2245494"]

rule all:
    input: expand(OUTPUT_DIR + "/exact_{run1}_{run2}.txt", zip, run1=runs_1, run2=runs_2)

rule exact_compare:
    threads: 1

    output:
        op = OUTPUT_DIR + "/exact_{run1}_{run2}.txt"
    input:
        kmc_intersect = OUTPUT_DIR + "/{run1}_{run2}_intersect.tsv",
        kmc_1_json = OUTPUT_DIR + "/{run1}.json",
        kmc_2_json = OUTPUT_DIR + "/{run2}.json",
    
    run:
        import json
        unique_kmers_1 = int(json.load(open(input.kmc_1_json, 'r'))["Stats"]["#Unique_k-mers"])
        unique_kmers_2 = int(json.load(open(input.kmc_2_json, 'r'))["Stats"]["#Unique_k-mers"])
        min_kmers = min(unique_kmers_1, unique_kmers_2)
        shared_kmers = 0
        with open(input.kmc_intersect) as R: 
            for _ in R: shared_kmers += 1
        
        containment = (int(shared_kmers) / min_kmers) * 100
        
        with open(f"exact_{wildcards.run1}_{wildcards.run2}.txt", 'w') as W:
            W.write(str(containment))


rule kmc_intersect:
    threads: 1
    
    output:
        kmc_intersect = OUTPUT_DIR + "/{run1}_{run2}_intersect.tsv"

    input:
        kmc_pre_1 = OUTPUT_DIR + "/{run1}.kmc_pre",
        kmc_pre_2 = OUTPUT_DIR + "/{run2}.kmc_pre",
        kmc_suf_1 = OUTPUT_DIR + "/{run1}.kmc_suf",
        kmc_suf_2 = OUTPUT_DIR + "/{run2}.kmc_suf",
        kmc_json_1 = OUTPUT_DIR + "/{run1}.json",
        kmc_json_2 = OUTPUT_DIR + "/{run2}.json",
        OUTDIR = OUTPUT_DIR,

    params:
        kmc_1 = OUTPUT_DIR + "/{run1}",
        kmc_2 = OUTPUT_DIR + "/{run2}",

    shell: """
        mkdir  -p /scratch/mhussien/ && cd /scratch/mhussien/
        kmc_tools simple {params.kmc_1} -ci1 {params.kmc_2} -ci1 intersect {wildcards.run1}_{wildcards.run2}_intersect -ci1
        kmc_tools transform {wildcards.run1}_{wildcards.run2}_intersect -ci1 dump -s {wildcards.run1}_{wildcards.run2}_intersect.tsv
        mv {wildcards.run1}_{wildcards.run2}_intersect.tsv {input.OUTDIR}
    """


rule kmc_count:
    threads: 16
    resources:
        mem_mb=27000
    
    output:
        kmc_pre = OUTPUT_DIR + "/{sample}.kmc_pre",
        kmc_suf = OUTPUT_DIR + "/{sample}.kmc_suf",
        kmc_json = OUTPUT_DIR + "/{sample}.json"

    input:
        r1   = FASTQ_DIR + "/{sample}_1.fastq.gz",
        r2   = FASTQ_DIR + "/{sample}_2.fastq.gz",
        OUTDIR = OUTPUT_DIR,

    shell: """
        mkdir  -p /scratch/mhussien/ && cd /scratch/mhussien/
        echo ls -1 {wildcards.sample}/*gz > list_{wildcards.sample}.tmp
        kmc -v -k25 -m25 -fq -t16 -sf16 -ci1 -sr16  -sf16 -j{wildcards.sample}.json @list_{wildcards.sample}.tmp {wildcards.sample} .
        rm list_{wildcards.sample}.tmp
        mv {wildcards.sample}*  {input.OUTDIR}
    """