public without sharing class NotesTableController {
    
    // String accountId = System.currentPageReference().getParameters().get('school');
    // String stringStartDate = System.currentPageReference().getParameters().get('startDate');
    // String stringEndDate = System.currentPageReference().getParameters().get('endDate');


    
    Date startDate;
    Date endDate;

    List<notesSearcherController.WrapperNotes> notes ;
    private limitWrapper[] thousandBlocks = new limitWrapper[]{};
    private final integer listLimit;

    public NotesTableController()
    {

        String accountId = System.currentPageReference().getParameters().get('school');
        String stringStartDate = System.currentPageReference().getParameters().get('startDate');
        String stringEndDate = System.currentPageReference().getParameters().get('endDate');
        
        startDate = String.isNotBlank(stringStartDate)? Date.parse(stringStartDate):null;
        endDate = String.isNotBlank(stringEndDate)? Date.parse(stringEndDate):null;
        listLimit = 1000;
        notes = notesSearcherController.getNotes(accountId,startDate,endDate);
    }

    // public List<notesSearcherController.WrapperNotes> getNotes() {

        
    //     return this.notes;
    // }
    public limitWrapper[] getThousandBlocks()
    {
        thousandBlocks = new limitWrapper[]{};
        
        integer counter = 0;
        integer loopCount = 0;
        notesSearcherController.WrapperNotes[] tmpNotes = new notesSearcherController.WrapperNotes[]{};
        
        for(notesSearcherController.WrapperNotes n: this.notes)
        {
            if(counter < listLimit)
            {
                tmpNotes.add(n);
                counter++;
            }
            else
            {
                loopCount++;
                thousandBlocks.add(new limitWrapper(tmpNotes,loopCount));
                tmpNotes = new notesSearcherController.WrapperNotes[]{};
                tmpNotes.add(n);
                counter = 0;
            }            
        }
        
        if(thousandBlocks.size() == 0)
        {
            loopCount++;
            thousandBlocks.add(new limitWrapper(tmpNotes,loopCount));
        }
        
        return thousandBlocks;
    }


    public class limitWrapper
    {
        public List<notesSearcherController.WrapperNotes> notes {get;set;}
        public integer blockNumber {get;set;}
        public limitWrapper(List<notesSearcherController.WrapperNotes> nots, integer i)
        {
            notes = nots;
            blockNumber = i;
        }
        
    }
}