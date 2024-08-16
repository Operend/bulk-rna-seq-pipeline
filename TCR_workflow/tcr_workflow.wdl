task MiXCR {
    File mi_license 
    File fastq1
    File fastq2
    String docker
    String species
    String material
    Int preemptible_count
    String prefix
    Int num_threads

    command <<<
        mixcr activate-license < ${mi_license}
        mixcr analyze shotgun --starting-material ${material} -s ${species} -t ${num_threads} --only-productive ${fastq1} ${fastq2} ${prefix}
    >>>
        output {
        File report = "${prefix}.report"
        File ALL = "${prefix}.clonotypes.ALL.txt"
        File clns = "${prefix}.clns"
        File vdjca = "${prefix}.vdjca"
        }

        runtime {
        disks: "local-disk 64 HDD"
        memory: "32 GB"
        docker: docker
        cpu: "${num_threads}"
        preemptible: preemptible_count
        }
}

task TRUST {
    File ref_fasta_IMGT
    File ref_fasta
    File input_bam
    String prefix
    String docker
    Int preemptible_count

    command <<<
          /opt2/TRUST4/run-trust4 -b ${input_bam} -f ${ref_fasta} --ref ${ref_fasta_IMGT} -o ${prefix}

    >>>

        output {
        File out_cdr3="${prefix}_cdr3.out"
        File trustfinal="${prefix}_final.out"
        File trustreport="${prefix}_report.tsv"
        File trustraw="${prefix}_raw.out"
        File trustannot="${prefix}_annot.fa"
        }

        runtime {
        disks: "local-disk 64 HDD"
        memory: "8 GB"
        docker: docker
        preemptible: preemptible_count
    }
}    


workflow tcr_workflow {
    String prefix

    call TRUST{
        input: prefix=prefix
    }

    call MiXCR{
        input: prefix=prefix
    }
}