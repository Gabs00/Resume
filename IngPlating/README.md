##Purpose
  The purpose of this application is to store recipes and ingredient prices.
  The user can then load a recipe and determine the price per plate(based on smallest dish made).
  or price per dish. It will also show total price including labor (user settable)
  
  Then the program will be able to export to CSV the the prices, showing all costs.
  
  Price per plate will be based on total ingredients used to make the dish. Meaning if only 2 plates were sold,
  on a dish that has a serving size of 4, price per plate will be (Dish cost / 4).

((Rough Draft))

##Classes
###Ingrediant class
	Name
	Walmart ID
	Walmart Category
	MSRP
	Total Unit Size price
	Measured Unit
	Methods to convert to different units
	
###Recipe class
	has a list of ingrediants
	has ingrediant amounts in a unit
	has instructions (User entered data)
	
###Interface class
	Has a list of Recipes
	shows information

Ingrediant Prices:
  Will use walmarts open API to get ingediant prices, during set up. Allow a method for the user to "browse"
  ingrediant options
