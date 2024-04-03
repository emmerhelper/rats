class event extends object {

      __New(gridview) {
      
            this.Row := gridview.currentCellRow

            this.Module := gridview.getCellValue(this.row,"SM_SHORT")
            this.moduleLetters := RegExReplace(this.Module,"\d+")
            this.moduleLastCharacter := SubStr(this.Module,StrLen(this.module))
            this.moduleNumbers := RegExReplace(this.Module,"\D+")

            this.Name := gridview.getCellValue(this.row,"D_SHORT")
            this.abbr := gridview.getCellValue(this.row,"E_SHORT")
            this.year := SubStr(this.ModuleNumbers,2,1)
            this.type := SubStr(this.Name,StrLen(this.name)-1,2)
            this.location := "Universal"
            
            this.isFirstSemester := Mod(this.moduleLastCharacter,2)
            this.isAfternoon := this.calculateAfternoon()
            this.day := this.calculateDay()
            this.time := this.calculateTime()
            this.room := this.calculatePerson()
            this.person := this.calculatePerson()
            this.capacity := this.calculateCapacities()
            this.registration := this.calculateRegistration()
      }

            calculateAfternoon(){
            if (this.moduleLastCharacter = 9 || this.moduleLastCharacter = 0){
                  return true 
            }
      }

      calculateDay(){ 
            day := {}
            day.number := this.calculateDayNumber()
            day.name := this.calculateDayName(day.number)
            return day
      }

      calculateDayNumber(){
            if (this.isFirstSemester){
                  number := (this.moduleLastCharacter + 1) / 2
            } else number := this.moduleLastCharacter / 2
            if (number = 5 || number = 0){
                  number := 1
            }
            return number
      }

      calculateDayName(number){
            days := ["MONDAY","TUESDAY","WEDNESDAY","THURSDAY"]
            return days[number]
      }

      calculateTime(){
            time := {}

            if this.isAfternoon {
                  if this.type = "LC"{
                        ;; Afternoon Lecture
                        time.start := "13:00:00"
                        time.end := "15:00:00"
                  } else {
                        ;; Afternoon Tutorial
                        time.start := "15:00:00"
                        time.end := "16:00:00"
                  }
            } else if this.type = "LC"{
                  ;; Morning Lecture
                  time.start := "09:00:00"
                  time.end := "11:00:00"
            } else {
                  ;; Morning Tutorial
                  time.start := "11:00:00"
                  time.end := "12:00:00"
            }

            return time
      }

      calculateRoom(){
            if this.type = "LC"{
                  return "U-10" this.year ".1"
            } else if this.type = "TU" {
                  return "U-20" this.year ".1"
            }
      }

      calculatePerson(){
            initial := -1

            switch this.moduleLetters {
                  case "MATHS":
                        initial += 10
                  case "ECO":
                        initial += 15
                  case "BSNS":
                        initial += 20
                  case "HRM":
                        initial += 25
                  case "LANG":
                        initial += 31
            }

            return initial + this.year 
      }

      calculateCapacities(){
            capacity := {}

            if this.type = "LC"{
                  capacity.minimum := "1"
                  capacity.optimum:= "50"
                  capacity.maximum:= "150"
            } else if this.type = "TU"{
                  capacity.minimum := "1"
                  capacity.optimum:= "20"
                  capacity.maximum:= "30"
            }

            return capacity
      }

      calculateRegistration(){
            registration := {}

            if this.isFirstSemester {
                  registration.start := "01.01.2024"
                  registration.end := "31.08.2025"
                  registration.withdrawal := "31.08.2025"
                  registration.feedback := "31.12.2024"
            } else {
                  registration.start := "01.01.2024"
                  registration.end := "31.08.2025"
                  registration.withdrawal := "31.08.2025"
                  registration.feedback := "31.05.2025"
            }

            return registration
      }

      calculateSemester(){
            if this.IsFirstSemester{
                  return "3"
            } else return "4"
      }

      scheduleRegular(session,gridview){
            ;; If there's already an event, edit instead of change
            if this.abbr{
                  gridview.pressToolbarContextButton("PB_CHANGE")
                  gridview.selectContextMenuItem("SCHED_EVT")
            } else {
                  gridview.pressToolbarContextButton("PB_CREATE")
                  gridview.selectContextMenuItem("CREATE_REGEVT")
            }
          
            userArea := session.findByID("wnd[0]/usr")
            
            ;; Capacity
            findTextElement(userArea,"PIQACADOFFERDETAIL_EV-KAPZ1_EV").text := this.capacity.minimum
            findTextElement(userArea,"PIQACADOFFERDETAIL_EV-KAPZ2_EV").text := this.capacity.optimum
            findTextElement(userArea,"PIQACADOFFERDETAIL_EV-KAPZ3_EV").text := this.capacity.maximum

            ;; Location
            findTextElement(userArea,"PIQACADOFFERDETAIL_EV-SHORT_F_EV").text := this.location
            session.findById("wnd[0]").sendVKey(0)
            session.findByID("wnd[1]/tbar[0]/btn[0]").Press()

            ;; Registration
            findTextElement(userArea,"PIQACADOFFERDETAIL_EV-/ITED/REG_BEGIN_DATE").text := this.registration.start
            findTextElement(userArea,"PIQACADOFFERDETAIL_EV-/ITED/REG_END_DATE").text := this.registration.end
            findTextElement(userArea,"PIQACADOFFERDETAIL_EV-/ITED/DEREG_END_DATE").text := this.registration.withdrawal

            ;; Relative Start - 1 day after start of class period
            findTextElement(userArea,"PIQACADOFFERDETAIL_EV-PLPERLIMBEG_EV").text := "1"
            userArea.FindByName("PIQACADOFFERDETAIL_EV-PLPERLIMBEGU_EV","GuiComboBox").key := "8"

            ;; Relative End - 14 weeks after start of class period
            findTextElement(userArea,"PIQACADOFFERDETAIL_EV-PLPERLIMEND_EV").text := "14"
            userArea.FindByName("PIQACADOFFERDETAIL_EV-PLPERLIMENDU_EV","GuiComboBox").key := "7"

            ;; Start Day
            userArea.FindByName("PIQACADOFFERDETAIL_EV-SCHEDBGDAY_EV","GuiComboBox").key := this.day.number

            ;; Start and end time
            findTextElement(userArea,"GS_SCHEDELEM-BEGUZ").text := this.time.start
            findTextElement(userArea,"GS_SCHEDELEM-ENDUZ").text := this.time.end
            
            ;; Day of the week
            userArea.FindByName("GS_SCHEDELEM-" this.day.name,"GuiCheckBox").selected := 1

            ;; Person
            userArea.FindByName("GS_SCHEDELEM-INSTR_OTYPE","GuiComboBox").key := "P"
            findTextElement(userArea,"GS_SCHEDELEM-INSTR_SHORT").text := this.person
            session.findById("wnd[0]").sendVKey(0)
            session.findByID("wnd[1]/usr/btnBUTTON_1").Press()

            ;; Room
            findTextElement(userArea,"GS_SCHEDELEM-ROOM_SHORT").setFocus()
            session.findById("wnd[0]").sendVKey(4)
            session.findByID("wnd[1]/usr/btnBUTTON_1").Press()
            session.findById("wnd[1]/usr/tabsG_SELONETABSTRIP/tabpTAB001/ssubSUBSCR_PRESEL:SAPLSDH4:0220/sub:SAPLSDH4:0220/txtG_SELFLD_TAB-LOW[0,24]").text := this.room
            session.findById("wnd[1]/tbar[0]/btn[0]").press()
            session.findById("wnd[1]/tbar[0]/btn[0]").press()

            ;; Press generate and hope it works?
            userArea.FindByName("GV_BUT_SCHEDGENERATE","GuiButton").Press()

            ;; Annoying stuff in the way
            session.findById("wnd[1]/usr/btnBUTTON_1").press()
            session.findById("wnd[1]/tbar[0]/btn[0]").press()
            
            ; Save
            session.findById("wnd[0]").sendVKey(11)
            session.findByID("wnd[1]/tbar[0]/btn[0]").Press()
            
      }
}     