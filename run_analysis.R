#Download the Files into R
packages <- c("data.table", "tidyr", "dplyr")
sapply(packages, library, character.only = TRUE, quietly = TRUE)

path <- getwd()
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

download.file(path, "DataFiles.zip")
unzip(zipfile = "DataFiles.zip")



### read Activity Labels and Features into R

ActivityLabels <- read.table(file.path(path, "UCI HAR Dataset/activity_labels.txt"),
                             col.names = c("ClassLabels", "ActivityName"))

features <- read.table(file.path(path, "UCI HAR Dataset/features.txt"))
        colnames(features) <- c("Index", "FeatureName")

featureswanted <- grep("(mean|std)", features[ , 2])
        measurements <- features[featureswanted, 2]
        measurements <- gsub('[()]', '', measurements)


## Making our Test Data frame
Test <- read.table(file.path(path, "UCI HAR Dataset/test/X_test.txt"))
        Test <- Test[ , featureswanted]
        colnames(Test) <- measurements

subject_test <- read.table(file.path(path, "UCI HAR Dataset/test/subject_test.txt"),
                           col.names = "Subject")
activity_test <- read.table(file.path(path, "UCI HAR Dataset/test/y_test.txt"),
                       col.names = "Activity")

TestDF <- cbind(subject_test, activity_test, Test)

## Loading our Train Data Frame

Train <- read.table(file.path(path, "UCI HAR Dataset/train/X_train.txt"))
        Train <- Train[ , featureswanted]
        colnames(Train) <- measurements

subject_train <- read.table(file.path(path, "UCI HAR Dataset/train/subject_train.txt"),
                            col.names = "Subject")
activity_train <- read.table(file.path(path, "UCI HAR Dataset/train/y_train.txt"),
                             col.names = "Activity")

TrainDF <- cbind(subject_train, activity_train, Train)

##Merge Data from Training and Test data sets

MergedDF <- rbind(TestDF, TrainDF)

## Change Activity Labels to Named Activities

MergedDF[["Activity"]] <- factor(MergedDF[ , "Activity"], 
                                 levels = ActivityLabels[["ClassLabels"]],
                                 labels = ActivityLabels[["ActivityName"]])


##  Create second tidy data set with the Avg of each column
subjectivity <- unite(MergedDF, Subject, Activity, col = "Sub_Activity", sep = "_")
by_subactivity <- group_by(subjectivity, Sub_Activity)
finalDF <- by_subactivity %>% summarise_all(mean)

## Write out Tidy data set as .TXT file
write.table(x = finalDF, file = "TidyData.txt", quote = FALSE, row.names = FALSE)
