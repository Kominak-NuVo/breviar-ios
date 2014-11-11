//
//  BRPrayer.m
//  Breviar
//
//  Created by Gyimesi Akos on 9/7/12.
//
//

#import "BRPrayer.h"
#import "BRCGIQuery.h"
#import "BRSettings.h"
#import "BRUtil.h"

@interface BRPrayer ()
@property(strong) NSString *cachedBody;
@end

@implementation BRPrayer

@synthesize prayerType;
@synthesize title;
@synthesize body;

static NSString *prayerQueryIds[] = {
    [BRInvitatory]         = @"mi",
    [BROfficeOfReadings]   = @"mpc",
    [BRMorningPrayer]      = @"mrch",
    [BRMidMorningPrayer]   = @"mpred",
    [BRMiddayPrayer]       = @"mna",
    [BRMidAfternoonPrayer] = @"mpo",
    [BREveningPrayer]      = @"mv",
    [BRCompline]           = @"mk"
};

static NSString *prayerNames[] = {
    [BRInvitatory]         = @"Invitatory",
    [BROfficeOfReadings]   = @"Readings",
    [BRMorningPrayer]      = @"Laudes",
    [BRMidMorningPrayer]   = @"Tertia",
    [BRMiddayPrayer]       = @"Sexta",
    [BRMidAfternoonPrayer] = @"Nona",
    [BREveningPrayer]      = @"Vespers",
    [BRCompline]           = @"Compline"
};

static NSString *propriaCalendarIds[] = {
    [BRCalSKGeneral]          = @"sk",
    [BRCalCZGeneral]          = @"cz",
    [BRCalCZ_OP]              = @"czop",
    [BRCalSK_CSSR]            = @"cssr",
    [BRCalHUGeneral]          = @"hu",
    [BRCalSK_SVD]             = @"svd",
    [BRCalSK_SJ]              = @"sj",
    [BRCalSK_SDB]             = @"sdb",
    [BRCalSK_OFM]             = @"ofm",
    [BRCalSK_OP]              = @"op",
    [BRCalSK_CM]              = @"cm",
    [BRCalCZ_OPRAEM]          = @"opraem",
    [BRCalCZ_OFMCAP]          = @"ofmcap",
    [BRCalCZ_CSSR]            = @"czcssr",
    [BRCalCZ_SDB]             = @"czsdb"
};

static NSString *propriaCalendarNames[] = {
    [BRCalSKGeneral]          = @"v�eobecn� [pre Slovensko]",
    [BRCalCZGeneral]          = @"obecn� [pro �echy a Moravu]",
    [BRCalCZ_OP]              = @"CZ OP", // not used
    [BRCalSK_CSSR]            = @"pre Kongreg�ciu najsv. Vykupite�a � redemptoristov (CSsR)",
    [BRCalHUGeneral]          = @"�ltal�nos [Magyarorsz�g]",
    [BRCalSK_SVD]             = @"pre Spolo�nos� Bo�ieho Slova � verbistov (SVD)",
    [BRCalSK_SJ]              = @"pre Spolo�nos� Je�i�ovu � jezuitov (SJ)",
    [BRCalSK_SDB]             = @"pre salezi�nsku rodinu � SDB, FMA, ASC",
    [BRCalSK_OFM]             = @"pre franti�k�nsku rodinu",
    [BRCalSK_OP]              = @"pre Reho�u kazate�ov � dominik�nov (OP)",
    [BRCalSK_CM]              = @"pre Misijn� spolo�nos� sv. Vincenta de Paul � lazaristov (CM)",
    [BRCalCZ_OPRAEM]          = @"s vlastn�mi texty premonstr�tsk�ho ��du (OPraem)"
    [BRCalCZ_OFMCAP]          = @"s vlastn�mi kapuc�nsk�mi texty (OFMCap)",
    [BRCalCZ_CSSR]            = @"s vlastn�mi texty Kongregace nejsv. Vykupitele � redemptorist� (CSsR)",
    [BRCalCZ_SDB]             = @"s vlastn�mi texty pro salesi�nskou rodinu" ,
};

- (NSString *)title {
    return BREVIAR_STR(prayerQueryIds[self.prayerType]);
}

- (NSString *)prayerName {
    return prayerNames[self.prayerType];
}

- (NSString *)queryId {
    return prayerQueryIds[self.prayerType];
}

- (NSString *)body {
    if (!self.cachedBody) {
        self.cachedBody = [self generateBody];
    }
    return self.cachedBody;
}

- (NSString *)generateBody {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:self.date];
    
    NSMutableDictionary *queryOptions = [NSMutableDictionary dictionary];
    [queryOptions addEntriesFromDictionary:[BRSettings instance].prayerQueryOptions];
    [queryOptions addEntriesFromDictionary:@{
                                             @"qt": @"pdt",
                                             @"d": [NSNumber numberWithInteger:components.day],
                                             @"m": [NSNumber numberWithInteger:components.month],
                                             @"r": [NSNumber numberWithInteger:components.year],
                                             @"p": prayerQueryIds[self.prayerType],
                                             @"ds": [NSNumber numberWithInteger:self.celebrationId],
                                             @"o0": @"65",
                                             @"o1": @"5440",
                                             @"o2": @"16384",
                                             @"o3": @"0",
                                             @"o4": @"0",
                                             @"o5": @"0"
                                             }];
    
    return [BRCGIQuery queryWithArgs:queryOptions];
}

+ (BRPrayerType)prayerTypeFromQueryId:(NSString *)queryId {
    int i;
    for (i=BRInvitatory; i<=BRCompline; i++) {
        if ([prayerQueryIds[i] isEqualToString:queryId]) {
            return (BRPrayerType)i;
        }
    }
    return BRInvitatory;
}

+ (NSString *)queryIdFromPrayerType:(BRPrayerType)prayerType {
    return prayerQueryIds[prayerType];
}

@end
