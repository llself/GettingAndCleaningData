GettingAndCleaningData
======================

Programming Assignment for Getting and Cleaning Data.  Taking in datasets related to wearable computing and pulling it in R and merging and cleaning the data.

The goal of this assignment is to pull in all the different datasets, merge them together, and then take that "messy" dataset and create a "tidy" data set.  From the tidy dataset, provide another dataset that gives you the mean values based on the subject and Activity being performed. 

I have provided this in the form of a script called run_Analysis.R


##My Assertions 
With this assignment, we had to make assertions on how we were going to provide a tidy dataset. My decision were:

*    I was creating a tidy data set that was long versus wide.  In our instructions for the assignment, it said it didn't matter which one, so I      
     chose to have a long data set after reading Hadley Wickham's Tidy Data document, found at http://vita.had.co.nz/papers/tidy-data.pdf.
     
*    We are only looking for mean and standard deviation data.  Therefore, my interpretation of that is I am not looking for the MeanFrequency   
     or angle values and will exclude that from my dataset. I am not looking for MeanFreq because that is just getting the mean of the frequency   
     of those activities for that individual. Since I am getting that mean later, I don't want to include that.  Secondly, the angle only had 
     mean and no standard deviation. The angle was defined as getting the angle between two vectors so I don't care about the mean of that as it       
     didn't represent the mean of the activity that was being performed.  Therefore in the original dataset, columns that had MeanFreq in the 
     name and or columns that started with angle were excluded from my dataset.  From the original dataset, I am keeping 33 standard deviation 
     columns and 33 mean columns from the original dataset.


##Why it is Tidy
Now that I have laid out my decisions, I will explain what I did to merge this data and make it tidy.

According to Hadley Wickham in his document, found at http://vita.had.co.nz/papers/tidy-data.pdf 
Messy Data includes:
1.  Column headers are values, not variable names
2.  Multiple variables are stored in one column
3.  Variables are stored in both rows and columns
4.  Multiple types of observational units are stored in the same table
5.  A single observational unit is stored in multiple tables

and that Tidy data is
1.  Each variable forms a column.
2.  Each observation froms a row.
3.  Each type of observational unit forms a table.

So, the data when I got it was messy because we had multiple tables that needed to be merged together because it was all data related to one observational unit and column headers that were values and not variable names.  In addition, the column headers which should be values has multiple variables stored in that one column name.  

So if you look at the run_Analysis.R script, you will see that I pulled in all the datasets, merged them together into one cohesive dataset and then I melted the data so that my column names became values like they should be and then I split the values that were once column names into four distinct descriptive columns.  I felt that the column names like t-BodyAcc()-mean-x really depicted four different characteristics of the measure value.  Therefore, I wanted to take the column name and split that into four different column variables called: 

  * Domain - which was indicated by the first letter being a t (time) or f(frequency) 
  * SignalType - which indicated type of signal like BodyAcc, BodyJerkAcc, BodyGyro, etc.
  * Calculation - which indicated if the calculation was the mean or the standard deviation
  * Axis - which indicated if it was using the x, y, z, axis to calculate.  If it didn't use any axis, it was labeled as NA.

Therfore, I ended up with a long tidy dataset that includes columns like Activity, SubjectID, Domain, SignalType, Calculaiton, Axis, and value, where value was our measure that we had, all of which adheres to the tidy data specifications. I only one variable in each column, each row is an observation of wearable computing and it is all contained into one dataset or table.  

##Steps I performed

1.  I brought in 8 datasets.   Once you download your file from the internet, I went in and took al the files/folders under UCI HAR Dataset up to under projectAssignment2 and removed that UCI HAR Dataset folder.  Three of these datas regarding the train folders and three with respect to the test folders. The last two datasets brought in the column names for the main dataset and brought in the activitylabels that represented the type of activity.  I.e. 1 - Walking, 2, Walking_Upstairs.   This is depicted in lines 16-23 of the run_Analysis.R script.  Once I brought them all in, I made sure the column names were added. See lines 26-32 of run_Analyis.R script.

2.  Now that I have all the data in R, I need to start merging the data in a fashion that keeps the integrity, so that we are matching datasets correctly.  As such, I column bind the three test datasets together into one dataset called testDS.  See line 35 of run_Analysis.R script. Then I repeat that column binding for the train datasets called trainDS.  See line 36 of the run_Analysis.R script. So each dataset has the subjectID, the ActivityType, and then all the measures in the original dataset all together.

3.  Now that I have all the train data in one dataset and all the test data in one dataset, I merged those together by using a rbind function.  I was able to use rbind because we had the exact same number of columns and they were the same name, so I just wanted to add all the rows in the testDS with all the rows in the trainDS.  See line 39 of the run_Analysis.R script.

4.  Now based on the second assertion above, I want to create a vector that game me the index of what columns I wanted to keep.  Remember, I am removing angle and MeanFreq from my list.  So I use the intersect function that provides me the values that are present in both grep functions and returns that vector index.  Therefore, the first list uses grep function that looks for all indexes where the column name has "Mean" or "mean" or std in any upper or lower case presentation and also looks for the ActivityType column that I already brought in and want to keep.
the second list is derived from the second grep function where it is looking for "MeanFreq" or "meanfreq" or "Meanfreq" or "meanFreq" in the column names and provides that list of indexes where that is NOT matching that criteria. So theintersect function gets me the indexed list where the index value is in both lists, which is what I want.  Also, since I have already merged my SubjectId and ActivityType, I am including that in my grep function to look for those at the beginning because I want to keep those rows and they do not have meanfreq or angle in them.  See lines 48-49 of the run_Analysis.R script.

5.  Now that i have the list of columns I want to keep, I am going to extract out only those and assign that to a dataset called, "WearableComputingDS".  See line 53 of the run_Analysis.R script.
     
6.  Since I am creating a long dataset, I need to clean up the column names.  We have special characters and each column name has really four different variables that should be created from it.  In order to clean this up, I had to use the gsub and sub functions to find all of the () and remove that completely from the list, then I converted - to _ so I knew where each different variable started.  Next, I converted columns that started with t to Time_ and those that started with f as Frequency_ .  I did that because I wanted to make that its own variable and have it spelled out what type of calculation was captured.  Lastly, I searched for all columns that didn't specify an axis that it was calculated on and made sure to append it with NA so that it would easily be melted into the four new columns later.  Now that we have cleaned up all the column names in a vector called WearableComputingColNames, I am going to apply the new names to my dataset, WearableComputingDS.  See lines 60-68 of the run_Analysis.R script.

7.  Now I am merging in the Activity Labels so I can replace the ActivityType values in my dataset (currently 1,2,3) with the actual values like (Walking, Walking Upstairs, etc).  I didn't do this earlier, because the merge function reorders the dataset, and I wanted to make sure all of my data was correct and I had everything the way it should be.  Now that I do, I want to bring those values in.   Once they are in, I can remove the ActivityType column which just contained the number of the Activity.  See line 72-74 of the run_Analysis.R script.

8.  Now that I have the true Activity Types in, I can melt my data.  In other words, take all those values that start with Time or Frequency and make the column name a value in one column and the measurement to be in one column called value.  See line 77 of the run_Analysis.R script.  

9.  Once I have the dataset melted down and assign that to a new dataset name of WearableComputingMeltedDS, I can now take that new column that contains all of the old column names and split those into four columns depicting the characteristic of that measurement by using the separate function, and applying that change to a new dataset called, WearableComputingTidyDS.  See line 82 of the run_Analysis.R script.  THIS dataset provides me my tidy dataset!

10.  Lastly, I am taking my tidy dataset and providing a new dataset, called MeanEachActivitybySubjectDS, that provides the mean of the measures for each Activity by the Subject.  See line 85 of the run_Analysis.R script.

