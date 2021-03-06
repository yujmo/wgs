#!/bin/bash

# Author: elon
# Description: 一个合并GVCF文件的模板
# Time: 2018-4-5

# 该脚本需要完成的是对各个样本分区的VCGF文件做一个merge操作
export SAMTOOLS=~/biosoft/samtools/1.0/bin
export GATK=~/biosoft/gatk/4.0/gatk
export HADOOP=~/hadoop/bin


# 定义参考序列
export REF=~/wgs/input/fasta/E.coli_K12_MG1655.fa


# 定义模板变量
INPUT_FILE=SRR1770413.g.vcf

cd /tmp

# 从HDFS上download所有的GVCF文件
$HADOOP/hadoop fs -get /wgs/output/gvcf/$INPUT_FILE \
&& echo "* * * * download gvcf done * * * *"

# merge all gvcf files -- E_coli_K12.vcf
time $GATK GenotypeGVCFs -R $REF -V $INPUT_FILE -O E_coli_K12.vcf && echo "** vcf done **"

## 1.为vcf文件压缩
time bgzip -f E_coli_K12.vcf

## 2.构建tabix索引
time $SAMTOOLS/tabix -p vcf E_coli_K12.vcf.gz

## 3. 上传最终的VCF文件以及索引文件到HDFS上
$HADOOP/hadoop fs -put E_coli_K12.vcf.gz* /wgs/output/vcf \
&& echo "* * * * 变异检测结果vcf文件上传到HDFS上 * * * *"
