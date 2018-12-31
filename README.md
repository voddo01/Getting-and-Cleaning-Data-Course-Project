# Getting-and-Cleaning-Data-Course-Project
This Contains the script that I used to clean the Human Activity Recognition using Smartphones dataset as found here:
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones#


### Load the packages we will be using, as well as downloading the dataset
packages <- c("data.table", "tidyr", "dplyr")
sapply(packages, library, character.only = TRUE, quietly = TRUE)

path <- getwd()
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

download.file(path, "DataFiles.zip")
unzip(zipfile = "DataFiles.zip")


### Read Activity Labels and Features into R
 ### ActivityLabels will be used a bit later to name the activities
ActivityLabels <- read.table(file.path(path, "UCI HAR Dataset/activity_labels.txt"),
                             col.names = c("ClassLabels", "ActivityName"))
 ### The Features will be the eventual column names as these are the active measurements of the experiment
features <- read.table(file.path(path, "UCI HAR Dataset/features.txt"))
        colnames(features) <- c("Index", "FeatureName")
 ### Since the prompt only wants the mean and standard deviation, here we create "featureswanted" to get rid of the rest
featureswanted <- grep("(mean|std)", features[ , 2])
        measurements <- features[featureswanted, 2]
        measurements <- gsub('[()]', '', measurements)


### Making our Test Data frame
  ### This first data frame is created using the data from the "Test" group with the subjects and their activities added
Test <- read.table(file.path(path, "UCI HAR Dataset/test/X_test.txt"))
        Test <- Test[ , featureswanted]
        colnames(Test) <- measurements

subject_test <- read.table(file.path(path, "UCI HAR Dataset/test/subject_test.txt"),
                           col.names = "Subject")
activity_test <- read.table(file.path(path, "UCI HAR Dataset/test/y_test.txt"),
                       col.names = "Activity")

TestDF <- cbind(subject_test, activity_test, Test)

### Loading our Train Data Frame
  ### This data frame is created using the data from the "Training" group with the subjects and their activities added
Train <- read.table(file.path(path, "UCI HAR Dataset/train/X_train.txt"))
        Train <- Train[ , featureswanted]
        colnames(Train) <- measurements

subject_train <- read.table(file.path(path, "UCI HAR Dataset/train/subject_train.txt"),
                            col.names = "Subject")
activity_train <- read.table(file.path(path, "UCI HAR Dataset/train/y_train.txt"),
                             col.names = "Activity")

TrainDF <- cbind(subject_train, activity_train, Train)

### Merge Data from Training and Test data sets
MergedDF <- rbind(TestDF, TrainDF)

### Change Activity Labels to Named Activities
  ### Uses the ActivityLabels from earlier to change our "Activity" variables from numbers to the six named activities
MergedDF[["Activity"]] <- factor(MergedDF[ , "Activity"], 
                                 levels = ActivityLabels[["ClassLabels"]],
                                 labels = ActivityLabels[["ActivityName"]])


###  Create second tidy data set with the mean of each measurement
  ### First we combine the subject and activity columns so that we can group the data frame by the 180 combinations
  ### of subjects and activities.  Then we can use summarise_all to find the mean of the non-grouped columns (the measurements)
subjectivity <- unite(MergedDF, Subject, Activity, col = "Sub_Activity", sep = "_")
by_subactivity <- group_by(subjectivity, Sub_Activity)
finalDF <- by_subactivity %>% summarise_all(mean)

### Write out Tidy data set as .CSV file
write.csv(x = finalDF, file = "TidyData.csv", quote = FALSE, row.names = FALSE)
