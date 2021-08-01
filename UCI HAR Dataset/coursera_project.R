#------------------------------------
# tidy_analysis.R
# Gustavo Seifer
# Getting and Cleaning Data
# August 2021
#------------------------------------

#--Loading packages
#-install.packages("data.table")
library(data.table)
library(tidyverse)

#--Set your working directory
getwd()
setwd("E:/Documentos/getting_and_cleaning")

#-- Download UCI data files from the web, unzip it, and specify time/date
URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
destFile <- "CourseDataset.zip"
if (!file.exists(destFile)){
  download.file(URL, destfile = destFile, mode='wb')
}
if (!file.exists("./UCI_HAR_Dataset")){
  unzip(destFile)
}
date_download <- date()

#--Setting new WD
setwd("./UCI HAR Dataset")

#--Reading Activity files
act_test <- read.table("./test/y_test.txt", header = F)
act_train <- read.table("./train/y_train.txt", header = F)

summary(act_test)
summary(act_train)

#--Reading features files
feat_test <- read.table("./test/X_test.txt", header = F)
feat_train <- read.table("./train/X_train.txt", header = F)

str(feat_test)
str(feat_train)

#--Reading subject files
sub_test <- read.table("./test/subject_test.txt", header = F)
sub_train <- read.table("./train/subject_train.txt", header = F)

#--Reading Activity Labels
act_labels <- read.table("./activity_labels.txt", header = F)

#--Reading Feature Names
feat_names <- read.table("./features.txt", header = F)

#--Merging dataframes: Features Test&Train,Activity Test&Train, Subject Test&Train
feat_data <- rbind(feat_test, feat_train)
sub_data <- rbind(sub_test, sub_train)
act_data <- rbind(act_test, act_train)

#--Renaming colums 
names(act_data) <- "ActivityN"
names(act_labels) <- c("ActivityN", "Activity")

#--Getting factor
activity <- left_join(act_data, act_labels, "ActivityN")[, 2]

#--Rename SubjectData columns
names(sub_data) <- "Subject"
#--Rename FeaturesData columns using columns from FeaturesNames
names(feat_data) <- feat_names$V2

#--Create one large Dataset with only these variables: SubjectData,  Activity,  FeaturesData
data_set <- cbind(sub_data, activity)
data_set <- cbind(data_set, feat_data)

#--Create New datasets by extracting only the measurements on the mean and standard deviation for each measurement
sub_feat_names <- feat_names$V2[grep("mean\\(\\)|std\\(\\)", feat_names$V2)]
data_names <- c("Subject", "activity", as.character(sub_feat_names))
data_set <- subset(data_set, select = data_names)

#--Rename the columns of the large dataset using more descriptive activity names
names(data_set)<-gsub("^t", "time", names(data_set))
names(data_set)<-gsub("^f", "frequency", names(data_set))
names(data_set)<-gsub("Acc", "Accelerometer", names(data_set))
names(data_set)<-gsub("Gyro", "Gyroscope", names(data_set))
names(data_set)<-gsub("Mag", "Magnitude", names(data_set))
names(data_set)<-gsub("BodyBody", "Body", names(data_set))

#--Create a second, independent tidy data set with the average of each variable for each activity and each subject
second_dataset<-aggregate(. ~Subject + activity, data_set, mean)
second_dataset<-second_dataset[order(second_dataset$Subject,second_dataset$activity),]

#--Save this tidy dataset locally
write.table(second_dataset, file = "new_tidy_data.txt",row.name=FALSE)

#--------------END

