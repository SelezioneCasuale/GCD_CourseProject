# Description of run_analysis.R
## Part I - analysis of the given data set

First, upload the "xlsx" library, to write the final dataset in excel format (install this package through "install.packages("xlsx")")

Then download the dataset in the current directory and unzip it.
Upload labels of activity and features.
After, upload train data (all the .txt files in the train folder) 
and test data(all the .txt files in the test folder).
features are in turn used to name columns of biota data sets
Column with subject's id is then called "Subject_ID" and the one with activity labels "Activity".

Such data are saved in the following variables

<!-- -->
    trainData

<!-- -->
    testData

Then merge the two datasets; given that column names are the same, instead of merge we can use r bind. This is realized in the following way
<!-- -->
	mergedData <- rbind(trainData,testData)

Hence, select only mean and standard deviation for each feature. In order to create a new dataset (newData), first select columns containing the words "mean" OR "std" through "grepl"

<!-- -->
	select <- grepl("mean|std",names(mergedData))

Then create two 'buffers', the first with subject id and activity, the second with selected mean and std data

<!-- -->
	buffer <- mergedData[,c("Subject_ID","Activity")]
    buffer2<- mergedData[,select]
    newData <- cbind(buffer,buffer2)


Now, give names to activity class. This can be done looping through the labels

<!-- -->
    var <- newData$Activity
    for (i in 1:length(var)) {
          var[i] <- as.character(labels[var[i],2])
    }
    newData$Activity <- var

Finally, we can order our data by subject_id

<!-- -->
    newData <- newData[order(newData$Subject_ID),]

## Part II - creating a second tidy data set

First, define unique subjects_id (1:30). This is stored in variable 'ids'. 
Then we subset only newData rows for the first subject (stored in 'sub'). 
We then use the 'by' function to evaluate the mean of all of the columns representing features and convert this 'by' object into a data frame. this can be done by the following code snippet

<!-- -->
    subo <- by(sub[,c(3:dim(newData)[2])],sub$Activity,FUN=colMeans)
    subo <- as.data.frame(do.call(rbind,subo))

Everything is stored in a variable called 'subo'. We then define a variable called 'addenda', where we store subject_id (repeated for six times, the number of activities) and names of activities themselves. Then add column names and bind sub with addenda


<!-- -->
    subo <- cbind(addenda,subo)

This can be done in a loop for all subjects


<!-- -->
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


Finally, we save the resulting data set in an .xlsx file, in the current directory






