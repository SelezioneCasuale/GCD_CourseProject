# The final dataset will be saved in .xlsx format
library(xlsx)
# The UCI HAR Dataset will be downloaded and unzipped in your current directory
# downlaod the dataset 
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="UCI_HAR_Dataset.zip",method="curl")
unzip("UCI_HAR_Dataset.zip")
# Now you can access the actual dataset
setwd("UCI HAR Dataset")
# load files with activity labels and features
labels <- read.table("activity_labels.txt"); features <- read.table("features.txt")
# we create the train data set
# starting from the UCI HAR Dataset, we move to train folder
setwd("train")
# we are interested to all the .txt files in this directory
names <- list.files(pattern = "\\.txt$")
id <- 1:length(names)
# create a long list with all data
trainList <- lapply(names[id],read.csv,header=TRUE,sep="")
# than we create the data frame
trainData <- do.call(cbind,trainList)
# give names to columns
colnames(trainData) <- c("Subject_ID",as.character(features[,2]),"Activity")
# clear workspace from trainList
rm(trainList)

# go to the test directory
setwd("../test")
# and create the test data with the same method
names <- list.files(pattern = "\\.txt$")
id <- 1:length(names)
testList <- lapply(names[id],read.csv,header=TRUE,sep="")
testData <- do.call(cbind,testList)
colnames(testData) <- c("Subject_ID",as.character(features[,2]),"Activity")
rm(testList)
#now we can merge the two datasets
mergedData <- rbind(trainData,testData)
# extract only mean and sd for each measurement
select <- grepl("mean|std",names(mergedData))
buffer <- mergedData[,c("Subject_ID","Activity")]
buffer2<- mergedData[,select]
newData <- cbind(buffer,buffer2)
#give labels to Activity
var <- newData$Activity
for (i in 1:length(var)) {
        var[i] <- as.character(labels[var[i],2])
}
newData$Activity <- var
# for elegance, order the data set by subject_id
newData <- newData[order(newData$Subject_ID),]

# Part II - creating a second tidy data set

# Quite a lot of typing, but pretty fast 
ids <- unique(newData$Subject_ID)
id_match <- newData$Subject_ID == ids[1]
sub <- newData[id_match,]
subo <- by(sub[,c(3:dim(newData)[2])],sub$Activity,FUN=colMeans)
subo <- as.data.frame(do.call(rbind,subo))
addenda <- data.frame(rep(ids[1],dim(subo)[1]),sort(labels[,2]))
colnames(addenda)<-c("Subject_ID","Activity")
subo <- cbind(addenda,subo)

for (i in 2:length(ids)) {
        id_match <- newData$Subject_ID == ids[i]
        sub <- newData[id_match,]
        subo2 <- by(sub[,c(3:dim(newData)[2])],sub$Activity,FUN=colMeans)
        subo2 <- as.data.frame(do.call(rbind,subo2))
        addenda <- data.frame(rep(ids[i],dim(subo2)[1]),sort(labels[,2]))
        colnames(addenda)<-c("Subject_ID","Activity")
        subo2 <- cbind(addenda,subo2)
        subo <- rbind(subo,subo2)
}
# Here I order the data by activity, instead of subject.
# now save the dataset in the 'home' directory (i.e., where we started from)
setwd("../../")
write.xlsx(x = subo, file = "dataSet.xlsx", sheetName = "Data", row.names=FALSE)





        
        
        

