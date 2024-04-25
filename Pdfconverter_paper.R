#author: Shreya Nuguri (nugurishreya@gmail.com)
#Date created: 4/25/2024
#Version: 0.1.0
#Description: Compiled the data in multiple pdf files to a single excel sheet
#####Setting working directories and loading libraries#####
wd <- setwd("C:/Users/Public/Documents/Agilent/MicroLab/Results")
getwd()

#Install packages if not already installed
list.of.packages <- c("readxl", "readr", "dplyr")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

library(readxl)
library(readr)
library(dplyr)

####Create list of pdf files#######
myfiles <- choose.files(filters= "pdf")

##Converting pdf file and text files, creating list of the text files##
#nf <- n(myfiles)
#mytxtfiles <- vector(mode = list, "length" = nf)
#mytxtfiles[1:nf] <- lapply(myfiles[1:4], function(i) system(paste('"C:/Users/shrey/Desktop/xpdf-tools-win-4.03/xpdf/bin64/pdftotext.exe"', paste0('"', i, '"'))) )
lapply(myfiles, function(i) system(paste('"C:/Users/shrey/Desktop/OneDrive - The Ohio State University/Desktop/OSU/Lab/Syngenta/Important Syngenta 2023/xpdf-tools-win-4.03/xpdf/bin64/pdftotext.exe"', paste0('"', i, '"'))) )

mytxtfiles <- list.files(pattern = "txt") 
mytxtfiles <- mytxtfiles[!mytxtfiles=="RPTTemplates.txt"]

##Creating vector of components#
a <- read_tsv(mytxtfiles[1])
#date_time <- toString(substr(a[12,1],1,9))
#df_title <- data.frame(unlist(strsplit(date_time, split="/")))
df_title <- data.frame(c("Date Time"))
df_title_1 <- data.frame(unlist(strsplit(toString(a[2,1]), split=" "))) 
colnames(df_title) <- "Title"
colnames(df_title_1) <- "Title"
df_title <- bind_rows(df_title, df_title_1)

##Data wrangling (combines the data from all files)##
n <- as.numeric(length(myfiles))
for (i in 1:n){
  b <- read_tsv(mytxtfiles[i])
  df_content <- data.frame(unlist(strsplit(toString(b[3,1]), split=" ")))
  colnames(df_content) <- "s"
  #adding date and time
  # date <- data.frame(toString(substr(b[11,1],12,22)))
  # colnames(date) <- "s"
  # time <- data.frame(toString(substr(b[12,1],23,33)))
  # colnames(time) <- "s"
  date_time <- data.frame(toString(b[7,1]))
  colnames(date_time) <- "s"
  df_content <- bind_rows(date_time,df_content) 
  #names the column with sample ID#
  nm <- b[5,1]
  name <- substr(nm, 12, nchar(nm))
  colnames(df_content) <- name
  
  df_title <- bind_cols(df_title, df_content)
}

#####Tranposing rows into columns#####
df_title <- t(df_title)

#####Making the first row of wavenumbers the column name of the dataframe#####
colnames(df_title) = df_title[1, ] # the first row will be the header
df_title = df_title[-1, ]          # removing the first row.

#####Writing the dataframe into a CSV file in the working directory#####
write.csv(df_title, "Compiled.csv")

##Deleting txt file extension##

sapply(mytxtfiles, unlink)






