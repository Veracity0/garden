import <vprops.ash>;

// "breakfast" allows you to specify a single crop from your garden.
// Alternatively, you can specify "Harvest Anything" or "Harvest Nothing"
//
// Since there are seven different kinds of garden, unless you want to
// always or never harvest your garden, you need to change your
// breakfast setting every time you change your garden.
//
// This script lets you specify crops for all of the gardens and will
// harvest as appropriate.

// ***************************
//          To Do            *
// ***************************

// Nothing known.

// ***************************
//       Configuration       *
// ***************************

//-------------------------------------------------------------------------
// All of the configuration variables have default values, which apply
// to any character who does not override the variable using the
// appropriate property.
//
// You can edit the default here in the script and it will apply to all
// characters which do not override it.
//
// define_property( PROPERTY, TYPE, DEFAULT )
// define_property( PROPERTY, TYPE, DEFAULT, COLLECTION )
// define_property( PROPERTY, TYPE, DEFAULT, COLLECTION, DELIMITER )
//
// Otherwise, you can change the value for specific characters in the gCLI:
//
//     set PROPERTY=VALUE
//
// Both DEFAULT and a property VALUE will be normalized
//
// All properties used directly by this script start with "VGH."
//-------------------------------------------------------------------------

// Pumpkin Patch
//    "pumpkin"                         days 1-4: 1 pumpkin per day
//    "huge pumpkin"                    days 5-10: 1 huge pumpkin
//    "ginormous pumpkin"               day 11+: 1 ginormous pumpkin
// Peppermint Patch
//    "peppermint sprout"               days 1-4: 3 peppermint sprouts per day
//    "giant candy cane"                day 5+: 1 giant candy cane
// Bone Garden
//    "skeleton"                        days 1-5: 5 skeletons per day
//    "skulldozer"                      day 6+: fight with skulldozer
// Beer Garden
//    "barley"                          days 1-7: 3 handfuls of barley and 3 clusters of hops per day
//    "beer label"                      day 3: + 1 fancy beer bottle and 1 fancy beer label
//    "2 beer labels"                   day 5: + 2 fancy beer bottles and 2 fancy beer labels
//    "3 beer labels"                   day 7+: + 3 fancy beer bottles and 3 fancy beer labels
// Winter Garden
//    "ice harvest"                     days 1-7: 3 ice harvests and 3 snow berries per day
//    "frost flower"                    days 3-7+: + 1 frost flower
// Thanksgarden
//    "cornucopia"                      day 1: 1 cornucopia
//    "3 cornucopias"                   day 2: 3 cornucopias
//    "5 cornucopias"                   day 3: 5 cornucopias
//    "8 cornucopias"                   day 4: 8 cornucopias
//    "11 cornucopias"                  day 5: 11 cornucopias
//    "15 cornucopias"                  day 6: 15 cornucopias
//    "magacopia"                       day 7+: 1 megacopia
// Tall Grass Patch
//    "tall grass"                      days 1-7: 1 patch of tall grass per day
//    "very tall grass"                 days 8+: 1 patch of very tall grass
// Mushroom Garden
//    "free-range mushroom"             day 1: 1 free-range mushroom
//    "plump free-range mushroom"       day 2: 1 plump free-range mushroom
//    "bulky free-range mushroom"       day 3: 1 bulky freerange mushroom
//    "giant free-range mushroom"       day 4: 1 giant free-range mushroom
//    "immense free-range mushroom"     day 5: 1 immense free-range mushroom
//    "colossal free-range mushroom"    day 11+: 1 colossal free-range mushroom
// Rock Garden (plot 1)
//    "groveling gravel"                day 1: 1 groveling gravel
//    "2 groveling gravel"              day 2: 2 handfuls of groveling gravel
//    "3 groveling gravel"              day 3: 3 handfuls of groveling gravel
//    "fruity pebble"                   day 4: 1 fruity pebble
//    "2 fruity pebbles"                day 5: 2 fruity pebbles
//    "3 fruity pebbles"                day 6: 3 fruity pebbles
//    "lodestone"                       day 7+: lodestone
// Rock Garden (plot 2)
//    "milestone"                       day 1: 1 milestone
//    "2 milestones"                    day 2: 2 milestones
//    "3 milestones"                    day 3: 3 milestones
//    "bolder boulder"                  day 4: 1 bolder boulder
//    "2 bolder boulders"               day 5: 2 bolder boulders
//    "3 bolder boulders"               day 6: 3 bolder boulders
//    "molehill mountain"               day 7+: molehill mountain
// Rock Garden (plot 3)
//    "whet stone"                      day 1: 1 whet stone
//    "2 whet stones"                   day 2: 2 whet stones
//    "3 whet stones"                   day 3: 3 whet stones
//    "hard rock"                       day 4: 1 hard rocks
//    "2 hard rocks"                    day 5: 2 hard rocks
//    "3 hard rocks"                    day 6: 3 hard rocks
//    "strange stalagmite"              day 7+: strange stalagmite
//
// You may specify one crop from each kind of garden, separated by "|".
// If you specify no crops, picking your garden will be deferred to
// breakfast.
//
// A setting that will harvest all the normal aftercore crops:
//
// "pumpkin|peppermint sprout|skeleton|3 beer labels|frost flower|15 cornucopias|very tall grass|colossal free-range mushroom|lodestone|molehill mountain|strange stalagmite"
//
// You don't have to specify crops for all types of garden. If you do
// not include crops from a particular garden, this script will not
// harvest that kind of garden.

// When I was developing automatic coercion in ASH, I caused an issue here.
// We can't recover, but we can uncorrupt the property, at least.

if ( get_property( "VGH.GardenCrops" ) == "aggregate boolean [string]" ) {
    print( "*** The VGH.GardenCrops property is corrupt. Resetting to default." );
    remove_property( "VGH.GardenCrops" );
}

string_set garden_crops = define_property( "VGH.GardenCrops", "string", "pumpkin|peppermint sprout|skeleton|3 beer labels|frost flower|15 cornucopias|very tall grass|colossal free-range mushroom|lodestone|molehill mountain|strange stalagmite", "set" );

// The Tall Grass Patch has an additional wrinkle: you can use Pok&eacute;-Gro fertilizer to advance its growth
// You will find up to three of these over the course of adventuring per day, if this is your current garden.
//
// This script can optionally use fertilizer in inventory to grow additional tall grass in your Tall Grass Patch.

boolean use_fertilizer = define_property( "VGH.FertilizeGrassPatch", "boolean", "false" ).to_boolean();

// ***************************
//        Validation         *
// ***************************

static item PUMPKIN = $item[ pumpkin ];
static item HUGE_PUMPKIN = $item[ huge pumpkin ];
static item GINORMOUS_PUMPKIN = $item[ ginormous pumpkin ];

static string_set pumpkin_crops = $strings[
    pumpkin,
    huge pumpkin,
    ginormous pumpkin
];

static item PEPPERMINT_SPROUT = $item[ peppermint sprout ];
static item GIANT_CANDY_CANE = $item[ giant candy cane ];

static string_set peppermint_crops = $strings[
    peppermint sprout,
    giant candy cane
];

static item SKELETON = $item[ skeleton ];

static string_set bone_crops = $strings[
    skeleton,
    skulldozer
];

static item BARLEY = $item[ handful of barley ];
static item BEER_LABEL = $item[ fancy beer label ];

static string_set beer_crops = $strings[
    barley,
    beer label,
    2 beer labels,
    3 beer labels
];

static item ICE_HARVEST = $item[ ice harvest ];
static item FROST_FLOWER = $item[ frost flower ];

static string_set winter_crops = $strings[
    ice harvest,
    frost flower
];

static item CORNUCOPIA = $item[ cornucopia ];
static item MEGACOPIA = $item[ megacopia ];

static string_set thanksgarden_crops = $strings[
    cornucopia,
    3 cornucopias,
    5 cornucopias,
    8 cornucopias,
    11 cornucopias,
    15 cornucopias,
    megacopia
];

static item GRASS_SEEDS = $item[ packet of tall grass seeds ];

static string_set grass_crops = $strings[
    tall grass,
    very tall grass
];

static item MUSHROOM_SPORES = $item[ packet of mushroom spores ];
static item FREE_RANGE_MUSHROOM = $item[ free-range mushroom ];
static item PLUMP_FREE_RANGE_MUSHROOM = $item[ plump free-range mushroom ];
static item BULKY_FREE_RANGE_MUSHROOM = $item[ bulky free-range mushroom ];
static item GIANT_FREE_RANGE_MUSHROOM = $item[ giant free-range mushroom ];
static item IMMENSE_FREE_RANGE_MUSHROOM = $item[ immense free-range mushroom ];
static item COLOSSAL_FREE_RANGE_MUSHROOM = $item[ colossal free-range mushroom ];

static string_set mushroom_crops = $strings[
    free-range mushroom,
    plump free-range mushroom,
    bulky free-range mushroom,
    giant free-range mushroom,
    immense free-range mushroom,
    colossal free-range mushroom
];

static item ROCK_SEEDS = $item[ packet of rock seeds ];

static item GROVELING_GRAVEL = $item[ groveling gravel ];
static item FRUITY_PEBBLE = $item[ fruity pebble ];
static item LODESTONE = $item[ lodestone ];

static string_set rock_plot1_crops = $strings[
    groveling gravel,
    2 groveling gravel,
    3 groveling gravel,
    fruity pebble,
    2 fruity pebbles,
    3 fruity pebbles,
    lodestone
];

static item MILESTONE = $item[ milestone ];
static item BOLDER_BOULDER = $item[ bolder boulder ];
static item MOLEHILL_MOUNTAIN = $item[ molehill mountain ];

static string_set rock_plot2_crops = $strings[
    milestone,
    2 milestones,
    3 milestones,
    bolder boulder,
    2 bolder boulders,
    3 bolder boulders,
    molehill mountain
];

static item WHET_STONE = $item[ whet stone ];
static item HARD_ROCK = $item[ hard rock ];
static item STRANGE_STALAGMITE = $item[ strange stalagmite ];

static string_set rock_plot3_crops = $strings[
    whet stone,
    2 whet stones,
    3 whet stones,
    hard rock,
    2 hard rocks,
    3 hard rocks,
    strange stalagmite
];

static item FERTILIZER = $item[ Pok&eacute;-Gro fertilizer ];
int fertilizer_available = available_amount( FERTILIZER );

string vgh_pumpkin_crop;
string vgh_peppermint_crop;
string vgh_bone_crop;
string vgh_beer_crop;
string vgh_winter_crop;
string vgh_thanksgarden_crop;
string vgh_grass_crop;
string vgh_mushroom_crop;
string vgh_rock_plot1_crop;
string vgh_rock_plot2_crop;
string vgh_rock_plot3_crop;

void validate_crops()
{
    if ( count( garden_crops ) > 0 ) {
	string_set crops;
	foreach crop in garden_crops {
	    if ( pumpkin_crops contains crop ) {
		if ( vgh_pumpkin_crop != "" ) {
		    print( "VGH.GardenCrops: Pumpkin Patch crop specified multiple times; ignoring '" + crop + "'." );
		    continue;
		}
		vgh_pumpkin_crop = crop;
	    } else if ( peppermint_crops contains crop ) {
		if ( vgh_peppermint_crop != "" ) {
		    print( "VGH.GardenCrops: Peppermint Patch crop specified multiple times; ignoring '" + crop + "'." );
		    continue;
		}
		vgh_peppermint_crop = crop;
	    } else if ( bone_crops contains crop ) {
		if ( vgh_bone_crop != "" ) {
		    print( "VGH.GardenCrops: Bone Garden crop specified multiple times; ignoring '" + crop + "'." );
		    continue;
		}
		vgh_bone_crop = crop;
	    } else if ( beer_crops contains crop ) {
		if ( vgh_beer_crop != "" ) {
		    print( "VGH.GardenCrops: Beer Garden crop specified multiple times; ignoring '" + crop + "'." );
		    continue;
		}
		vgh_beer_crop = crop;
	    } else if ( winter_crops contains crop ) {
		if ( vgh_winter_crop != "" ) {
		    print( "VGH.GardenCrops: Winter Garden crop specified multiple times; ignoring '" + crop + "'." );
		    continue;
		}
		vgh_winter_crop = crop;
	    } else if ( thanksgarden_crops contains crop ) {
		if ( vgh_thanksgarden_crop != "" ) {
		    print( "VGH.GardenCrops: Thanksgarden crop specified multiple times; ignoring '" + crop + "'." );
		    continue;
		}
		vgh_thanksgarden_crop = crop;
	    } else if ( grass_crops contains crop ) {
		if ( vgh_grass_crop != "" ) {
		    print( "VGH.GardenCrops: Grass crop specified multiple times; ignoring '" + crop + "'." );
		    continue;
		}
		vgh_grass_crop = crop;
	    } else if ( mushroom_crops contains crop ) {
		if ( vgh_mushroom_crop != "" ) {
		    print( "VGH.GardenCrops: Mushroom crop specified multiple times; ignoring '" + crop + "'." );
		    continue;
		}
		vgh_mushroom_crop = crop;
	    } else if ( rock_plot1_crops contains crop ) {
		if ( vgh_rock_plot1_crop != "" ) {
		    print( "VGH.GardenCrops: Rock plot 1 crop specified multiple times; ignoring '" + crop + "'." );
		    continue;
		}
		vgh_rock_plot1_crop = crop;
	    } else if ( rock_plot2_crops contains crop ) {
		if ( vgh_rock_plot2_crop != "" ) {
		    print( "VGH.GardenCrops: Rock plot 2 crop specified multiple times; ignoring '" + crop + "'." );
		    continue;
		}
		vgh_rock_plot2_crop = crop;
	    } else if ( rock_plot3_crops contains crop ) {
		if ( vgh_rock_plot3_crop != "" ) {
		    print( "VGH.GardenCrops: Rock plot 3 crop specified multiple times; ignoring '" + crop + "'." );
		    continue;
		}
		vgh_rock_plot3_crop = crop;
	    } else {
		print( "VGH.GardenCrops: unknown crop '" + crop + "'; ignoring" );
		continue;
	    }

	    crops[ crop ] = true;
	}

	// Normalize property
	if ( garden_crops != crops ) {
	    set_property( "VGH.GardenCrops", crops );
	    garden_crops = crops;
	}
    }
}

// ***************************
//       Master Control      *
// ***************************

void harvest_garden()
{
    void print_crop( string garden, string name, string plural, int n )
    {
	print( "Your " + garden + " has " + ( n == 1 ? ( "1 " + name ) : ( n + " " + plural ) ) + " in it." );
    }

    void print_crop( string garden, item it, int n )
    {
	print_crop( garden, it.name, it.plural, n );
    }

    boolean harvest_pumpkins( item it, int n )
    {
	print_crop( "Pumpkin Patch", it, n );
	if ( vgh_pumpkin_crop == "" ) {
	    print( "You do not want to automatically harvest this kind of garden." );
	    return false;
	}
	print( "You want to harvest " + vgh_pumpkin_crop );
	switch ( vgh_pumpkin_crop ) {
	case "pumpkin":
	    // A pumpkin or anything better. I.e., anything.
	    return n > 0;
	case "huge pumpkin":
	    // A huge pumpkin or anything better.
	    return it == HUGE_PUMPKIN || it == GINORMOUS_PUMPKIN;
	case "ginormous pumpkin":
	    // Only a ginormous pumpkin
	    return it == GINORMOUS_PUMPKIN;
	}
	return false;
    }

    boolean harvest_peppermint( item it, int n )
    {
	print_crop( "Peppermint Patch", it, n );
	if ( vgh_peppermint_crop == "" ) {
	    print( "You do not want to automatically harvest this kind of garden." );
	    return false;
	}
	print( "You want to harvest " + vgh_peppermint_crop );
	switch ( vgh_peppermint_crop ) {
	case "peppermint sprout":
	    // A peppermint sprout or anything better. I.e., anything.
	    return n > 0;
	case "giant candy cane":
	    // Only a giant candy cane
	    return it == GIANT_CANDY_CANE;
	}
	return false;
    }

    boolean harvest_bones( item it, int n )
    {
	if ( n == -1 ) {
	    print( "Your Bone Garden has a Skulldozer in it." );
	    if ( my_adventures() < 1 ) {
		print( "Fighting it takes a turn, but you have none left today." );
		print( "You can fight it drunk. Perhaps you should have a drink?" );
		return false;
	    }
	    if ( vgh_bone_crop == "skulldozer" ) {
		return true;
	    }
	    print( "Gear up and fight it!" );
	    return false;
	}

	print_crop( "Bone Garden", it, n );
	if ( vgh_bone_crop == "" ) {
	    print( "You do not want to automatically harvest this kind of garden." );
	    return false;
	}
	print( "You want to harvest " + vgh_bone_crop );
	if ( vgh_bone_crop == "skulldozer" ) {
	    return false;
	}
	// If we saw skeletons, harvest them.
	return n > 0;
    }

    boolean harvest_beer( item it, int n )
    {
	print_crop( "Beer Garden", it, n );
	if ( vgh_beer_crop == "" ) {
	    print( "You do not want to automatically harvest this kind of garden." );
	    return false;
	}
	print( "You want to harvest " + vgh_beer_crop );
	switch ( vgh_beer_crop ) {
	case "barley":
	    // barley or anything better. I.e., anything.
	    return n > 0;
	case "beer label":
	    // 1 (or more) beer labels
	    return it == BEER_LABEL;
	case "2 beer labels":
	    // 2 (or more ) beer labels
	    return it == BEER_LABEL && n >= 2;
	case "3 beer labels":
	    // 3 beer labels
	    return it == BEER_LABEL && n == 3;
	}
	return false;
    }

    boolean harvest_winter( item it, int n )
    {
	print_crop( "Winter Garden", it, n );
	if ( vgh_winter_crop == "" ) {
	    print( "You do not want to automatically harvest this kind of garden." );
	    return false;
	}
	print( "You want to harvest " + vgh_winter_crop );
	switch ( vgh_winter_crop ) {
	case "ice harvest":
	    // any number of ice harvests. I.e., anything
	    return n > 0;
	case "frost flower":
	    // A frost flower
	    return it == FROST_FLOWER;
	}
	return false;
    }

    boolean harvest_thanksgarden( item it, int n )
    {
	print_crop( "Thanksgarden", it, n );
	if ( vgh_thanksgarden_crop == "" ) {
	    print( "You do not want to automatically harvest this kind of garden." );
	    return false;
	}
	print( "You want to harvest " + vgh_thanksgarden_crop );
	switch ( vgh_thanksgarden_crop ) {
	case "cornucopia":
	    // Any number of cornucopias. I.e., anything
	    return n > 0;
	case "3 cornucopias":
	    // 3 (or more cornucopias)
	    return ( it == CORNUCOPIA && n >= 3 ) || it == MEGACOPIA;
	case "5 cornucopias":
	    return ( it == CORNUCOPIA && n >= 5 ) || it == MEGACOPIA;
	case "8 cornucopias":
	    return ( it == CORNUCOPIA && n >= 8 ) || it == MEGACOPIA;
	case "11 cornucopias":
	    return ( it == CORNUCOPIA && n >= 11 ) || it == MEGACOPIA;
	case "15 cornucopias":
	    return ( it == CORNUCOPIA && n >= 15 ) || it == MEGACOPIA;
	case "megacopia":
	    return it == MEGACOPIA;
	}
	return false;
    }

    int pre_fertilize_grass( int n )
    {
	// If you do not want to harvest very tall grass, do not want to use fertilizer, or have no fertilizer, nothing to do
	if ( vgh_grass_crop != "very tall grass" || !use_fertilizer || fertilizer_available == 0 ) {
	    return 0;
	}

	// Don't prefertilize if can't achieve 8 grass patches
	int fertilizer_needed = max( 8 - n, 0 );
	return fertilizer_available < fertilizer_needed ? 0 : fertilizer_needed;
    }

    boolean harvest_grass( int n, int fertilizer_used )
    {
	if ( fertilizer_used > 0 ) {
	    print( "(After using " + fertilizer_used + " " + FERTILIZER + ")" );
	    n += fertilizer_used;
	}

	string name = n < 8 ? "patch of tall grass" : "patch of very tall grass";
	string plural = n == 1 ? "patch of tall grass" : n == 8 ? "patch of very tall grass" : "patches of tall grass";
	print_crop( "Tall Grass Garden", name, plural, n );
	if ( vgh_grass_crop == "" ) {
	    print( "You do not want to automatically harvest this kind of garden." );
	    return false;
	}
	print( "You want to harvest " + vgh_grass_crop );
	switch ( vgh_grass_crop ) {
	case "tall grass":
	    // Tall grass or anything better. I.e., anything.
	    return n > 0;
	case "very tall grass":
	    // Only very tall grass
	    return n >= 8;
	}
	return false;
    }

    void fertilize_grass( int count )
    {
	// If you do not want to harvest grass, or do not want to use fertilizer, nothing to do
	if ( vgh_grass_crop == "" || !use_fertilizer || fertilizer_available == 0 ) {
	    return;
	}

	while ( count-- > 0 ) {
	    print( "" );
	    use( 1, FERTILIZER );
	    fertilizer_available--;
	}
    }

    void fertilize_and_pick_grass()
    {
	// This will be called after pre-fertilizing and picking your Tall Grass Patch
	// It will use up your remaining fertilizer for simple tall grass patches

	// If you do not want to harvest tall grass, or do not want to use fertilizer, nothing to do
	if ( vgh_grass_crop != "tall grass" || !use_fertilizer || fertilizer_available == 0 ) {
	    return;
	}

	print( "" );
	print( "Using up " + FERTILIZER + " harvesting tall grass." );

	// Tall grass or anything better. I.e., anything.
	// Must have fertilizer left after pre-fertilizing
	while ( fertilizer_available > 0 ) {
	    // Use up to 7 fertilizers before picking
	    fertilize_grass( min( fertilizer_available, 7 ) );
	    cli_execute( "garden pick" );
	}
    }

    boolean harvest_mushrooms( int n )
    {
	item spores_to_shroom()
	{
	    return
		n <= 1 ? FREE_RANGE_MUSHROOM :
		n == 2 ? PLUMP_FREE_RANGE_MUSHROOM :
		n == 3 ? BULKY_FREE_RANGE_MUSHROOM :
		n == 4 ? GIANT_FREE_RANGE_MUSHROOM :
		n >= 5 && n < 11 ? IMMENSE_FREE_RANGE_MUSHROOM :
		COLOSSAL_FREE_RANGE_MUSHROOM;
	}

	item shroom = spores_to_shroom();
	print_crop( "Mushroom Garden", shroom, 1 );
	if ( vgh_mushroom_crop == "" ) {
	    print( "You do not want to automatically harvest this kind of garden." );
	    return false;
	}
	print( "You want to harvest " + vgh_mushroom_crop );
	switch ( vgh_mushroom_crop ) {
	case "free-range mushroom":
	    return true;
	case "plump free-range mushroom":
	    return n >= 2;
	case "bulky free-range mushroom":
	    return n >= 3;
	case "giant free-range mushroom":
	    return n >= 4;
	case "immense free-range mushroom":
	    return n >= 5;
	case "colossal free-range mushroom":
	    return n >= 11;
	}
	return false;
    }

    boolean harvest_rock_plot1( item it, int n )
    {
	print_crop( "Rock Garden plot 1", it, n );
	if ( vgh_rock_plot1_crop == "" ) {
	    print( "You do not want to automatically harvest this kind of garden." );
	    return false;
	}
	print( "You want to harvest " + vgh_rock_plot1_crop );
	switch ( vgh_rock_plot1_crop ) {
	case "groveling gravel":
	    // At least 1 groveling gravel. I.e. anything
	    return n > 0;
	case "2 groveling gravel":
	    // At least 2 handfuls of groveling gravel - or anything later.
	    return it.name == "groveling gravel" ? n >= 2 : true;
	case "3 groveling gravel":
	    // At least 3 handfuls of groveling gravel - or anything later.
	    return it.name == "groveling gravel" ? n >= 3 : true;
	case "fruity pebble":
	    // At least 1 fruity pebble. I.e., anything past groveling gravel
	    return it != GROVELING_GRAVEL;
	case "2 fruity pebbles":
	    // At least 2 fruity pebbles - or anything later.
	    return it.name == "fruity pebble" ? n >= 2 : it != GROVELING_GRAVEL;
	case "3 fruity pebbles":
	    // At least 3 fruity pebbles - or anything later.
	    return it.name == "fruity pebble" ? n >= 3 : it != GROVELING_GRAVEL;
	case "lodestone":
	    // A lodestone
	    return it == LODESTONE;
	}
	return false;
    }

    boolean harvest_rock_plot2( item it, int n )
    {
	print_crop( "Rock Garden plot 2", it, n );
	if ( vgh_rock_plot2_crop == "" ) {
	    print( "You do not want to automatically harvest this kind of garden." );
	    return false;
	}
	print( "You want to harvest " + vgh_rock_plot2_crop );
	switch ( vgh_rock_plot2_crop ) {
	case "milestone":
	    // At least 1 milestone. I.e. anything
	    return n > 0;
	case "2 milestones":
	    // At least 2 milestones - or anything later.
	    return it.name == "milestone" ? n >= 2 : true;
	case "3 milestones":
	    // At least 3 milestones - or anything later.
	    return it.name == "milestones" ? n >= 3 : true;
	case "bolder boulder":
	    // At least 1 bolder boulder. I.e., anything past milestone
	    return it != MILESTONE;
	case "2 bolder boulders":
	    // At least 2 bolder boulders - or anything later.
	    return it.name == "bolder boulder" ? n >= 2 : it != MILESTONE;
	case "3 bolder boulders":
	    // At least 3 bolder boulders - or anything later.
	    return it.name == "bolder boulder" ? n >= 3 : it != MILESTONE;
	case "molehill mountain":
	    // A molehill mountain
	    return it == MOLEHILL_MOUNTAIN;
	}
	return false;
    }

    boolean harvest_rock_plot3( item it, int n )
    {
	print_crop( "Rock Garden plot 3", it, n );
	if ( vgh_rock_plot3_crop == "" ) {
	    print( "You do not want to automatically harvest this kind of garden." );
	    return false;
	}
	print( "You want to harvest " + vgh_rock_plot3_crop );
	switch ( vgh_rock_plot3_crop ) {
	case "whet stone":
	    // At least 1 whet stone. I.e. anything
	    return n > 0;
	case "2 whet stones":
	    // At least 2 whet stones - or anything later.
	    return it.name == "whet stone" ? n >= 2 : true;
	case "3 whet stones":
	    // At least 3 whet stones - or anything later.
	    return it.name == "whet stone" ? n >= 3 : true;
	case "hard rock":
	    // At least 1 hard rock. I.e., anything past whet stone
	    return it != WHET_STONE;
	case "2 hard rocks":
	    // At least 2 hard rocks - or anything later.
	    return it.name == "hard rock" ? n >= 2 : it != WHET_STONE;
	case "3 hard rocks":
	    // At least 3 hard rocks - or anything later.
	    return it.name == "hard rock" ? n >= 3 : it != WHET_STONE;
	case "strange stalagmite":
	    // A strange stalagmite
	    return it == STRANGE_STALAGMITE;
	}
	return false;
    }

    if ( count( garden_crops ) == 0 ) {
	return;
    }

    int [item] campground = get_campground();
    boolean have_garden = false;

    foreach it, n in campground {
	// You can only have one kind of garden in your campground.
	// 
	// A garden can have multiple plots, each with its own crop.
	//
	// If we detect such a plot, we must continue the loop and look
	// for additonal plots

	boolean should_harvest = false;
	string plot = "";

	// Certain kinds of garden require special handling
	boolean fight_skulldozer = false;
	boolean have_grass_patch = false;
	int pre_fertilize = 0;
	boolean have_mushroom_garden = false;

	switch ( it ) {
	case PUMPKIN:
	case HUGE_PUMPKIN:
	case GINORMOUS_PUMPKIN:
	    have_garden = true;
	    should_harvest = harvest_pumpkins( it, n );
	    break;
	case PEPPERMINT_SPROUT:
	case GIANT_CANDY_CANE:
	    have_garden = true;
	    should_harvest = harvest_peppermint( it, n );
	    break;
	case SKELETON:
	    have_garden = true;
	    should_harvest = harvest_bones( it, n );
	    fight_skulldozer = should_harvest && ( n == -1 );
	    break;
	case BARLEY:
	case BEER_LABEL:
	    have_garden = true;
	    should_harvest = harvest_beer( it, n );
	    break;
	case ICE_HARVEST:
	case FROST_FLOWER:
	    have_garden = true;
	    should_harvest = harvest_winter( it, n );
	    break;
	case CORNUCOPIA:
	case MEGACOPIA:
	    have_garden = true;
	    should_harvest = harvest_thanksgarden( it, n );
	    break;
	case GRASS_SEEDS:
	    have_garden = true;
	    have_grass_patch = true;
	    pre_fertilize = pre_fertilize_grass( n );
	    should_harvest = harvest_grass( n, pre_fertilize );
	    break;
	case MUSHROOM_SPORES:
	    have_garden = true;
	    have_mushroom_garden = true;
	    should_harvest = harvest_mushrooms( n );
	    break;
	case ROCK_SEEDS:
	    have_garden = true;
	    continue;
	case GROVELING_GRAVEL:
	case FRUITY_PEBBLE:
	case LODESTONE:
	    have_garden = true;
	    plot = "plot1";
	    should_harvest = harvest_rock_plot1( it, n);
	    break;
	case MILESTONE:
	case BOLDER_BOULDER:
	case MOLEHILL_MOUNTAIN:
	    have_garden = true;
	    plot = "plot2";
	    should_harvest = harvest_rock_plot2( it, n);
	    break;
	case WHET_STONE:
	case HARD_ROCK:
	case STRANGE_STALAGMITE:
	    have_garden = true;
	    plot = "plot3";
	    should_harvest = harvest_rock_plot3( it, n);
	    break;
	default:
	    continue;
	}

	if ( fight_skulldozer ) {
	    print( "Fight! Fight! Fight!" );
	    visit_url( "campground.php?action=garden" );
	    run_combat();
	    break;
	}

	if ( should_harvest ) {
	    print( "It's time to harvest!" );
	    if ( have_grass_patch ) {
		// Optionally fertilize it
		fertilize_grass( pre_fertilize );
		// Pick your crop
		cli_execute( "garden pick" );
		// Optionally fertilize and pick it
		fertilize_and_pick_grass();
		break;
	    }

	    // If a garden has multiple plots, pick it and look for more.
	    if (plot != "") {
		cli_execute( "garden pick " + plot );
		continue;
	    }

	    // Otherwise, pick the whole garden in one go.
	    cli_execute( "garden pick" );
	    break;
	}

	if ( have_mushroom_garden ) {
	    if ( vgh_mushroom_crop != "" ) {
		print( "Let's fertilize your mushroom so it will grow." );
		cli_execute( "garden fertilize" );
	    }
	    break;
	}

	print( "Let it grow some more." );

	// If you have a Tall Grass Patch, optionally fertilize and pick it
	if ( have_grass_patch ) {
	    fertilize_and_pick_grass();
	}

	// If the garden doesn't have multiple plots, we're done
	if ( plot == "" ) {
	    break;
	}
    }

    if (!have_garden) {
	print( "You don't have a garden in your campground." );
	return;
    }
}

void main()
{
    validate_crops();
    harvest_garden();
}