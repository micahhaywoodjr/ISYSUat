public class authNurseProfile {
    // Static variables are local to the context of a Web request 
    // (or testMethod during a runTests call) 
    // Therefore, this variable will be initialized as false 
    // at the beginning of each Web request which accesses it. 
    public static List<Profile> objP;
    
    static {
    	if(objP==null)
            objP = new List<Profile>([SELECT ID, Name FROM Profile WHERE Name = 'Custom - Nurse' Or Name = 'Custom - Sr Nurse']);
    }
    
}