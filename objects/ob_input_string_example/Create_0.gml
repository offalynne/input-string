/// @description Test setup

long_string = "";

//feather disable once all
repeat((__input_string()).max_length)
{
    // Fill with garbage
    long_string += chr(ord("A") + irandom(25));
}

callback = function()
{
    var _string = input_string_get();
    self.submission_test = "Callback test @" + string(current_time) + ": " + _string;
    // input_string_set(); // Clear on submission
};

submission_test = "";
input_string_callback_set(callback);

// Initial ticking state. Set to true for user ease,
// but suggest testing at false to be comprehensive.
ticking = true;

// Search test
search_test_index = -1;
search_test_list  = [
                     ["Aardvark", "Aardwolf", "Abyssinian", "Abyssinian Guinea Pig", "Acadian Flycatcher", "Achrioptera Manga", "Ackie Monitor", "Addax", "Adelie Penguin", "Admiral Butterfly", "Aesculapian Snake", "Affenpinscher", "Afghan Hound", "African Bullfrog", "African Bush Elephant", "African Civet", "African Clawed Frog", "African Fish Eagle", "African Forest Elephant", "African Golden Cat", "African Grey Parrot", "African Jacana", "African Palm Civet", "African Penguin", "African Sugarcane Borer", "African Tree Toad", "African Wild Dog", "Africanized bee (killer bee)", "Agama Lizard", "Agkistrodon Contortrix", "Agouti", "Aidi", "Ainu", "Airedale Terrier", "Airedoodle", "Akbash", "Akita", "Akita Shepherd", "Alabai (Central Asian Shepherd)", "Alaskan Husky", "Alaskan Klee Kai", "Alaskan Malamute", "Alaskan Pollock", "Alaskan Shepherd", "Albacore Tuna", "Albatross"],
                     ["White-Eyed Vireo", "White-Faced Capuchin", "White-shouldered House Moth", "White-tail deer", "White-Tailed Eagle", "Whitetail Deer", "Whiting", "Whoodle", "Whooping Crane", "Wild Boar", "Wildebeest", "Willow Flycatcher", "Willow Warbler", "Winter Moth", "Wire Fox Terrier", "Wirehaired Pointing Griffon", "Wirehaired Vizsla", "Wiwaxia", "Wolf", "Wolf Eel", "Wolf Snake", "Wolf Spider", "Wolffish", "Wolverine", "Woma Python", "Wombat", "Wood Bison", "Wood Frog", "Wood Tick", "Wood Turtle", "Woodlouse", "Woodlouse Spider", "Woodpecker", "Woodrat", "Wool Carder Bee", "Woolly Aphids", "Woolly Bear Caterpillar", "Woolly Mammoth", "Woolly Monkey", "Woolly Rhinoceros", "Worm", "Worm Snake", "Wrasse", "Writing Spider", "Wrought Iron Butterflyfish", "Wryneck", "Wyandotte Chicken", "Wyoming Toad", "X-Ray Tetra", "Xeme (Sabine’s Gull)", "Xenacanthus", "Xenoceratops"],
                    ];