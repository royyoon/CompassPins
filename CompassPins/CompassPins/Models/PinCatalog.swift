import Foundation

struct PinCatalog {
    static let all: [Pin] = [
        // North - Family (6 pins)
        Pin(
            name: "Names",
            journey: .north,
            supervision: "Adult partnership",
            requirements: "Learn the meaning and origin of your name and share it with your Circle.",
            examples: "• Research what your first name means\n• Find out who you were named after\n• Learn about your family surname history\n• Present what you learned to your Circle",
            imageURL: "Names",
            imageURLs: nil
        ),
        Pin(
            name: "Aims (7 Parts)",
            journey: .north,
            supervision: "Adult partnership",
            requirements: "Learn and recite the seven parts of the Adventure Guides Aims.",
            examples: "The 7 Aims:\n1. To support the parent-child relationship\n2. To enhance self-worth\n3. To strengthen family relationships\n4. To develop character\n5. To broaden horizons\n6. To develop social skills\n7. To have fun!",
            imageURL: "Aims",
            imageURLs: nil
        ),
        Pin(
            name: "Conduct",
            journey: .north,
            supervision: "Adult partnership",
            requirements: "Demonstrate understanding of the Adventure Guides Code of Conduct.",
            examples: "• Respect for others\n• Safety first\n• Teamwork and cooperation\n• Honesty and integrity\n• Taking care of nature\n• Being responsible",
            imageURL: "Conduct",
            imageURLs: nil
        ),
        Pin(
            name: "Dinner 4 Mom",
            journey: .north,
            supervision: "Adult partnership",
            requirements: "Plan and prepare a special dinner for your family.",
            examples: "Ideas:\n• Plan a 3-course meal\n• Set the table nicely\n• Make a menu card\n• Cook together with your parent\n• Serve the meal to your family",
            imageURL: "Dinner4Mom",
            imageURLs: nil
        ),
        Pin(
            name: "Dad and Child Camp trip",
            journey: .north,
            supervision: "Adult supervision",
            requirements: "Attend a Dad and Child camp trip or family camping adventure.",
            examples: "• YMCA campout\n• Family camping weekend\n• Backyard camping\n• Circle camping trip\n• Document your adventure with photos!",
            imageURL: "CampTrip",
            imageURLs: nil
        ),
        Pin(
            name: "Crafts",
            journey: .north,
            supervision: "Adult partnership",
            requirements: "Complete a craft project to share with your family or Circle.",
            examples: "Project ideas:\n• Birdhouse or bird feeder\n• Painted rock collection\n• Picture frame\n• Leather bracelet\n• Woodworking project",
            imageURL: "Crafts",
            imageURLs: nil
        ),

        // East - Nature (6 pins)
        Pin(
            name: "Plant & Grow",
            journey: .east,
            supervision: "Adult partnership",
            requirements: "Plant a seed or seedling and care for it as it grows. Document its progress.",
            examples: "Easy plants to grow:\n• Sunflowers\n• Tomatoes\n• Herbs (basil, mint)\n• Beans\n\nDocument with:\n• Weekly photos\n• Measure height\n• Journal about care",
            imageURL: "PlantGrow",
            imageURLs: nil
        ),
        Pin(
            name: "Hike",
            journey: .east,
            supervision: "Adult supervision",
            requirements: "Complete a nature hike of at least 2 miles and observe wildlife or plants.",
            examples: "Great SoCal trails:\n• Whiting Ranch\n• Crystal Cove\n• Laguna Coast Wilderness\n• Aliso & Wood Canyons\n\nBring: Water, snacks, camera, notebook",
            imageURL: "Hike",
            imageURLs: nil
        ),
        Pin(
            name: "Athletics",
            journey: .east,
            supervision: "Adult partnership",
            requirements: "Participate in an athletic activity or sport and demonstrate good sportsmanship.",
            examples: "Activities:\n• Join a sports team\n• Family bike ride\n• Rock climbing\n• Swimming\n• Skateboarding\n• Martial arts\n\nShow: Fair play, encouragement, respect",
            imageURL: "Athletics",
            imageURLs: nil
        ),
        Pin(
            name: "Family Tree",
            journey: .east,
            supervision: "Adult partnership",
            requirements: "Research and create a family tree going back at least two generations.",
            examples: "Include:\n• Your parents\n• Your grandparents\n• Great-grandparents (if possible)\n• Where they were born\n• Fun facts about each person\n\nCreate a poster or digital tree",
            imageURL: "FamilyTree",
            imageURLs: nil
        ),
        Pin(
            name: "Endangered Species",
            journey: .east,
            supervision: "Adult partnership",
            requirements: "Research an endangered species and present what you learned to your Circle.",
            examples: "Local endangered animals:\n• California Condor\n• Pacific Pocket Mouse\n• Arroyo Toad\n• Light-footed Clapper Rail\n\nResearch: Habitat, threats, conservation efforts",
            imageURL: "EndangeredSpecies",
            imageURLs: nil
        ),
        Pin(
            name: "Photo Scrap Book",
            journey: .east,
            supervision: "Adult partnership",
            requirements: "Create a photo scrapbook documenting your Adventure Guides activities.",
            examples: "Include:\n• Circle meeting photos\n• Campout memories\n• Pin completions\n• Friends you made\n• Add captions and dates\n• Decorate creatively",
            imageURL: "PhotoScrapbook",
            imageURLs: nil
        ),

        // South - Community (7 pins)
        Pin(
            name: "3 Animal Tracks",
            journey: .south,
            supervision: "Adult partnership",
            requirements: "Identify and document three different animal tracks in nature.",
            examples: "Common SoCal tracks:\n• Coyote (dog-like)\n• Raccoon (hand-like)\n• Deer (hoof)\n• Rabbit (oval pads)\n• Squirrel (tiny hands)\n\nDocument: Photo, drawing, or plaster cast",
            imageURL: "AnimalTracks",
            imageURLs: nil
        ),
        Pin(
            name: "National Park Report",
            journey: .south,
            supervision: "Adult partnership",
            requirements: "Research a National Park and present your findings to your Circle.",
            examples: "Nearby parks:\n• Joshua Tree\n• Channel Islands\n• Death Valley\n• Yosemite\n\nInclude: Location, wildlife, features, fun facts",
            imageURL: "NationalPark",
            imageURLs: nil
        ),
        Pin(
            name: "7 Native SoCal Animals",
            journey: .south,
            supervision: "Adult partnership",
            requirements: "Identify and learn about seven animals native to Southern California.",
            examples: "Native animals:\n• Coyote\n• Bobcat\n• California Ground Squirrel\n• Red-tailed Hawk\n• Western Fence Lizard\n• Banana Slug\n• Pacific Tree Frog\n\nLearn: Diet, habitat, behavior",
            imageURL: "NativeAnimals",
            imageURLs: nil
        ),
        Pin(
            name: "Special Trip",
            journey: .south,
            supervision: "Adult supervision",
            requirements: "Take a special trip to a museum, cultural site, or community landmark.",
            examples: "Ideas:\n• Bowers Museum\n• Discovery Cube\n• Mission San Juan Capistrano\n• Natural History Museum\n• Local historical site\n\nBring back: Ticket stub, brochure, photo",
            imageURL: "SpecialTrip",
            imageURLs: nil
        ),
        Pin(
            name: "Geology",
            journey: .south,
            supervision: "Adult partnership",
            requirements: "Learn about rocks, minerals, and geological formations in your area.",
            examples: "SoCal geology:\n• San Joaquin Hills\n• Santiago Peak\n• Beach sandstone\n\nRock types: Igneous, Sedimentary, Metamorphic\n\nStart a rock collection!",
            imageURL: "Geology",
            imageURLs: nil
        ),
        Pin(
            name: "Meteorology",
            journey: .south,
            supervision: "Adult partnership",
            requirements: "Study weather patterns and track weather for at least one week.",
            examples: "Track daily:\n• Temperature (high/low)\n• Cloud types (cumulus, stratus, cirrus)\n• Wind direction\n• Precipitation\n\nMake a weather chart or journal",
            imageURL: "Meteorology",
            imageURLs: nil
        ),
        Pin(
            name: "Reverse Role",
            journey: .south,
            supervision: "Adult supervision",
            requirements: "Complete a community service project helping others.",
            examples: "Service ideas:\n• Beach cleanup\n• Food bank volunteer\n• Help elderly neighbor\n• Donate toys/clothes\n• Park beautification\n• Make cards for nursing home",
            imageURL: "ReverseRole",
            imageURLs: nil
        ),

        // West - Fun (7 pins)
        Pin(
            name: "Stilts or Walking Stick",
            journey: .west,
            supervision: "Adult supervision",
            requirements: "Build stilts or a walking stick with adult supervision.",
            examples: "Walking stick:\n• Find sturdy branch (your height + 6\")\n• Remove bark\n• Sand smooth\n• Carve designs or paint\n• Add wrist strap\n• Seal with varnish",
            imageURL: "WalkingStick",
            imageURLs: nil
        ),
        Pin(
            name: "Knife Safety",
            journey: .west,
            supervision: "Adult supervision",
            requirements: "Demonstrate safe knife handling. Carve or whittle an object together with your adult. Present it to your Circle.",
            examples: "Safety rules:\n• Always cut AWAY from yourself\n• Keep blade sharp (dull = dangerous)\n• Close when not in use\n• Create safety circle (arm's length)\n\nFirst projects: Tent stake, butter knife, whistle",
            imageURL: "KnifeSafety",
            imageURLs: nil
        ),
        Pin(
            name: "Knots",
            journey: .west,
            supervision: "Adult partnership",
            requirements: "Learn and demonstrate six different knots and their uses.",
            examples: "1. SQUARE KNOT - Joining two ropes of equal size\n2. BOWLINE - Creates a fixed loop, rescue knot\n3. CLOVE HITCH - Attach rope to post or tree\n4. SHEET BEND - Join two ropes of different sizes\n5. TAUT-LINE HITCH - Adjustable loop for tent lines\n6. FIGURE-EIGHT - Stopper knot, prevents rope slipping\n\nPractice with rope until you can tie blindfolded!",
            imageURL: "Knots",
            imageURLs: nil
        ),
        Pin(
            name: "Fire Safety",
            journey: .west,
            supervision: "Adult supervision",
            requirements: "Learn fire safety rules and practice building a safe campfire.",
            examples: "Safety rules:\n• Clear 10ft circle\n• Water nearby\n• Never leave unattended\n• Drown, stir, feel (to extinguish)\n\nFire structure:\n• Tinder (dry leaves, paper)\n• Kindling (small twigs)\n• Fuel (larger sticks)",
            imageURL: "FireSafety",
            imageURLs: nil
        ),
        Pin(
            name: "First Aid",
            journey: .west,
            supervision: "Adult supervision",
            requirements: "Learn basic first aid skills including treating cuts, scrapes, and burns.",
            examples: "Skills to learn:\n• Clean and bandage cuts\n• Treat scrapes\n• Cool water for burns\n• R.I.C.E. for sprains (Rest, Ice, Compress, Elevate)\n• When to call 911\n• Recovery position\n\nPractice on dolls or stuffed animals",
            imageURL: "FirstAid",
            imageURLs: nil
        ),
        Pin(
            name: "Astronomy",
            journey: .west,
            supervision: "Adult partnership",
            requirements: "Observe the night sky and identify at least five constellations or planets.",
            examples: "Easy to find:\n• Big Dipper (always visible)\n• Orion (winter)\n• Cassiopeia (W-shape)\n• North Star (Polaris)\n• Planets: Venus, Mars, Jupiter (bright!)\n\nBest time: New moon, away from city lights\nUse: Star chart app",
            imageURL: "Astronomy",
            imageURLs: nil
        ),
        Pin(
            name: "Navigation",
            journey: .west,
            supervision: "Adult partnership",
            requirements: "Learn to use a compass and map for navigation. Complete an orienteering exercise.",
            examples: "Compass basics:\n• Red needle = North\n• Cardinal directions: N, S, E, W\n• Take a bearing (direction to target)\n\nExercise: Create treasure hunt\n• Draw simple map of park\n• Mark waypoints\n• Use compass to find targets",
            imageURL: "Navigation",
            imageURLs: nil
        )
    ]
}
