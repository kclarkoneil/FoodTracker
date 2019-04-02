# FoodTracker
Image app for tracking meals. 

- UIScrollView based initial screen that displays recently consumed meals with a photo and rating.
- If no meals have been created three default meals will be presented

![](images/Homescreen)

- User can edit meals by tapping, or add new meals via add new meal button
- Rating button is a custom UIControl that adjusts "Stars" and saves the numbers of stars selected as an integer
- Tapping the image gives user choice between selecting new image from gallery or taking and adding new image via camera

![](images/Edit-Meal)

-Once saved the meal is stored in a Firebase database with a reference to it's image which is stored in a 
Firebase storage bucket, the meal is instantiated on launch with image as property

![](images/Firebase-Database)
![](images/Firebase-StorageBucket)
