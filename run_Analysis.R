#run_Analysis.R Script
#Getting and Cleaning Data - Programming Assignment
#Leslie Self
#November 2014

#Install all packages needed for script
install.packages("data.table", "dplyr", "reshape2")
library(data.table, dplyr, reshape2)

#gets the zipped data location into fileURL and downloads
#warning - it takes a while to download
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL, destfile = "projectassignment2.zip", mode="wb")

#read in test & training files 
testDS <- read.table("projectassignment2/test/X_test.txt")
testActType <- read.table("projectassignment2/test/y_test.txt") 
testSubjects <- read.table("projectassignment2/test/subject_test.txt")
trainDS <- read.table("projectassignment2/train/X_train.txt")
trainActType <- read.table("projectassignment2/train/y_train.txt")
trainSubjects <- read.table("projectassignment2/train/subject_train.txt")
ActivityLabels <- read.table("projectassignment2/activity_labels.txt")
ColNamesDS <- read.table("projectassignment2/features.txt")

#Assigns the correct column names to datasets
colnames(testDS) <- ColNamesDS[,2]
colnames(testActType) <- "ActivityType"
colnames(testSubjects) <- "SubjectID"
colnames(trainDS) <- ColNamesDS[,2]
colnames(trainActType) <- "ActivityType"
colnames(trainSubjects) <- "SubjectID"
colnames(ActivityLabels) <- c("ActivityID", "Activity")

#Merge/Combine the two test datasets
testDS <- cbind(testSubjects,testActType, testDS)
trainDS <- cbind(trainSubjects, trainActType, trainDS)

#Merge Test and Train Datasets into one assignment
progAssignDS <- rbind(testDS, trainDS)

#provides me an indexed list of the columns that have mean in them and removes anything with mean frequency or angle
# intersects gets two vector lists and finds the values that are present in both and returns that vector index.  Therefore, 
# the first list uses grep function that looks for all indexes where the column name has "Mean" or "mean" or std in any upper or lower 
# case presentation and also looks for the ActivityType column that I already brought in and want to keep.
# the second list is derived from the second grep function where it is looking for "MeanFreq" or "meanfreq" or "Meanfreq" or "meanFreq"
# in the column names and provides that list of indexes where that is NOT matching that criteria.  
# So theintersect function gets me the indexed list where the index value is in both lists, which is what I want
ColumnIndexList <-intersect(grep("[Mm]ean|[Ss][Tt][Dd]|ActivityType|SubjectID", colnames(progAssignDS)), 
                          grep("[Mm]ean[Ff]req|^[Aa]ngle", colnames(progAssignDS), invert=TRUE))


#extracts out just the columns we need for a cleaner dataset
WearableComputingDS <- progAssignDS[, ColumnIndexList]

#Cleaning up Column Names - # 1st/2nd Row - using gsub to find all occurrences of () and -, and the first [] means there will be some 
# special characters to keep left but the second [] includes all special characters to remove from the dataset selected and I am replacing 
# the the () with nothing and the - to _ so I can use that to split the data later.  
# Then the 3rd and 4th row is looking if the first characters is a "t" or "f" and replaces it with for "Time_" and "Frequency_" respectively. 
# Lastly, the last two looks for the end being either mean or std and adds in a _NA so I can make that move to another attribute for axis later
WearableComputingColNames <- gsub("[][()]", "", names(WearableComputingDS))
WearableComputingColNames <- gsub("[][-]", "_", WearableComputingColNames)
WearableComputingColNames <- sub("^t", "Time_", WearableComputingColNames)
WearableComputingColNames <- sub("^f", "Frequency_", WearableComputingColNames)
WearableComputingColNames <- sub("mean$", "mean_NA", WearableComputingColNames)
WearableComputingColNames <- sub("std$", "std_NA", WearableComputingColNames)

#Now that I cleaned up the colnames, need to set my dataset with the new and improved names
colnames(WearableComputingDS) <- WearableComputingColNames

#Merges the new dataset with the ActivityLabels since we want to know the activity name and not id.  Had to wait to do this later 
#because merge functions reorders the data and I wanted to make sure the correct items were together.
WearableComputingDS <- merge(ActivityLabels, WearableComputingDS, by.x="ActivityID", by.y="ActivityType")
#remove ActivityID as we do not need now
WearableComputingDS <- WearableComputingDS[,-1]

#Melting the dataset to have a narrow tidy data set instead of a wide one.  Based on Hadley's Wickham's document
#Takes all the columns beside ActivityID, Activity and SubjectID and makes the column name a value in a column called variable and the number
# and puts that value in the column called "value" 
WearableComputingMeltedDS <- melt(WearableComputingDS, id=c("Activity", "SubjectID"),  measure.vars=grep("^Time|^Freq", colnames(WearableComputingDS)))

#Now that I have melted and have all those columns as a value, I can separate that field "variable" into columns that describe the data elements
# So the first part gives me domain (Time or Frequency), and second one is Single Type (i.e. BodyAcc, BodyGyro, BodyAccJerk, etc)
# the third for calculation type (std = standard deviation or mean) and lastly, Axis, which tell me which axis was calculated (x,y, z or NA)
WearableComputingTidyDS <- separate(WearableComputingMeltedDS, variable, c("Domain", "SignalType", "Calculation", "Axis"))


#Provides a dataframe that takes the Tidy dataset and gives us the mean of each Subject by Activity
 MeanEachActivitybySubjectDS<- as.data.frame(dcast(WearableComputingTidyDS, SubjectID ~ Activity, mean))