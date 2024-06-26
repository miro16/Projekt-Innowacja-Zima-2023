public with sharing virtual class RESTMedicalFacilityUtils {
    public class FacilityWrapper {
        public String id;
        public String name;
        public Address address;
        public Map<String, HourWrapper> operatingHours;

        public FacilityWrapper(String id, String name, Address address) {
            this.id = id;
            this.name = name;
            this.address = address;
            this.operatingHours = new Map<String, HourWrapper>();
        }

        public void addOperatingHours(String dayOfWeek, Time openingHour, Time closingHour) {
            this.operatingHours.put(dayOfWeek, new HourWrapper(openingHour, closingHour));
        }
    }

    public class Address {
        public String street_name;
        public String city;
        public Decimal flat_number;
        public Decimal street_number;
        public String postcode;
    
        public Address(String street_name, String city, Decimal flat_number, Decimal street_number, String postcode) {
            this.street_name = street_name;
            this.city = city;
            this.flat_number = flat_number;
            this.street_number = street_number;
            this.postcode = postcode;
        }
    }
    
    public class HourWrapper {
        public Time openingHour;
        public Time closingHour;

        public HourWrapper(Time openingHour, Time closingHour) {
            this.openingHour = openingHour;
            this.closingHour = closingHour;
        }
    }

    public static List<FacilityWrapper> listFacilities() {
        List<Medical_Facility__c> facilities = [SELECT Id, Name, City__c, Flat_Number__c, Postcode__c, Street_Name__c, Street_Number__c, 
        (SELECT Id, Day_of_Week__c, Opening_Time__c, Closing_Time__c FROM Operating_Hours__r) FROM Medical_Facility__c];

        List<FacilityWrapper> facilityWrappers = new List<FacilityWrapper>();

        for (Medical_Facility__c facility : facilities) {
            Address facilityAddress = new Address(
                facility.Street_Name__c,
                facility.City__c,
                facility.Flat_Number__c,
                facility.Street_Number__c,
                facility.Postcode__c
            );
        
            FacilityWrapper wrapper = new FacilityWrapper(
                facility.Id,
                facility.Name,
                facilityAddress
            );
        
            for (Operating_Hours__c operatingHours : facility.Operating_Hours__r) {
                wrapper.addOperatingHours(
                    operatingHours.Day_of_Week__c,
                    operatingHours.Opening_Time__c,
                    operatingHours.Closing_Time__c
                );
            }
        
            facilityWrappers.add(wrapper);
        }

        return facilityWrappers;
    }

    public static void updateFacility(FacilityWrapper facility, Medical_Facility__c tmp, List<Operating_Hours__c> operatingHoursToUpdate) {
        if(facility.name != NULL) {
            tmp.name = facility.name;
        }

        if (facility.operatingHours != null) {
            upsertHours(operatingHoursToUpdate, facility, tmp);
        }
    }

    public static void upsertHours(List<Operating_Hours__c> operatingHoursToUpdate, FacilityWrapper facility, Medical_Facility__c tmp) {
        for (String dayOfWeek : facility.operatingHours.keySet()) {
            HourWrapper hours = facility.operatingHours.get(dayOfWeek);

            Operating_Hours__c operatingHour = null;
            for (Operating_Hours__c tmpOperatingHour : tmp.Operating_Hours__r) {
                if (tmpOperatingHour.Day_of_Week__c == dayOfWeek) {
                    operatingHour = tmpOperatingHour;
                    break;
                }
            }

            if (operatingHour != null) {
                operatingHour.Opening_Time__c = hours.openingHour;
                operatingHour.Closing_Time__c = hours.closingHour;
                operatingHoursToUpdate.add(operatingHour);
            } else {
                operatingHoursToUpdate.add(new Operating_Hours__c(
                    Day_of_Week__c = dayOfWeek,
                    Opening_Time__c = hours.openingHour,
                    Closing_Time__c = hours.closingHour,
                    Medical_Facility__c = tmp.Id
                ));
            }
        }
    }

    public static List<FacilityWrapper> listFacilitiesFromIds(Set<Id> Ids) {
        List<Medical_Facility__c> facilities = [SELECT Id, Name, City__c, Flat_Number__c, Postcode__c, Street_Name__c, Street_Number__c, 
        (SELECT Id, Day_of_Week__c, Opening_Time__c, Closing_Time__c FROM Operating_Hours__r) FROM Medical_Facility__c WHERE Id IN :Ids];

        List<FacilityWrapper> facilityWrappers = new List<FacilityWrapper>();

        for (Medical_Facility__c facility : facilities) {
            Address facilityAddress = new Address(
                facility.Street_Name__c,
                facility.City__c,
                facility.Flat_Number__c,
                facility.Street_Number__c,
                facility.Postcode__c
            );
        
            FacilityWrapper wrapper = new FacilityWrapper(
                facility.Id,
                facility.Name,
                facilityAddress
            );
        
            for (Operating_Hours__c operatingHours : facility.Operating_Hours__r) {
                wrapper.addOperatingHours(
                    operatingHours.Day_of_Week__c,
                    operatingHours.Opening_Time__c,
                    operatingHours.Closing_Time__c
                );
            }
        
            facilityWrappers.add(wrapper);
        }

        return facilityWrappers;
    }
}