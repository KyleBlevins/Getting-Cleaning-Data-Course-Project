library(reshape2)

filename <- "getdata-projectfiles-UCI HAR Dataset.zip"

## Download and unpack
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

activities <- read.table("UCI HAR Dataset/activity_labels.txt")
activities[,2] <- as.character(activities[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Keep data on mean and standard dev
Keep <- grep(".*mean.*|.*std.*", features[,2])
Keep.names <- features[Keep,2]
Keep.names = gsub('-mean', 'Mean', Keep.names)
Keep.names = gsub('-std', 'Std', Keep.names)
Keep.names <- gsub('[-()]', '', Keep.names)


# Load the datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[Keep]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[Keep]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# merge data
allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", Keep.names)

allData$activity <- factor(allData$activity, levels = activities[,1], labels = activities[,2])
allData$subject <- as.factor(allData$subject)

allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

write.table(allData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
