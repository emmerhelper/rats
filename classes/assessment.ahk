#Include event.ahk

class assessment extends event {
      
      __New(module){

            this.Module := module
            this.moduleLetters := RegExReplace(this.Module,"\d+")
            this.moduleLastCharacter := SubStr(this.Module,StrLen(this.module))
            this.moduleNumbers := RegExReplace(this.Module,"\D+")

            this.type := "LC"
            this.location := "Universal"
            this.examMode := "WRIT"
            this.year := SubStr(this.ModuleNumbers,2,1)


            this.isFirstSemester := Mod(this.moduleLastCharacter,2)
            this.semester := this.calculateSemester()
            this.isAfternoon := this.calculateAfternoon()
            this.day := this.calculateDay()
            this.time := this.calculateTime()
            this.room := this.calculatePerson()
            this.person := this.calculatePerson()
            this.capacity := this.calculateCapacities()
            this.registration := this.calculateRegistration()
            this.date := this.calculateDate()

      }

      calculateDate(){
            if this.isFirstSemester{
                  return this.dateFirstSemester()
            } else return this.dateSecondSemester()
      }
      


      dateFirstSemester(){
            date := []
            DD := Integer(1 + this.day.number)
            MM := "12"
            YYYY := "2024"
            loop 3 {
                  DD += 7
                  date.Push(Format("{:02}",DD) "." MM "." YYYY)
            }
            return date 
      }

      dateSecondSemester(){
            date := []
            DD :=  Integer(4 + this.day.number)
            MM := "05"
            YYYY := "2025"
            loop 3 {
                  DD += 7
                  date.Push(Format("{:02}",DD) "." MM "." YYYY)
            }
            return date
      }

      schedule(){
            session := sapConnect()
            session.startTransaction("PIQEVALM")
            userArea := session.findByID("wnd[0]/usr")
            gridView := session.findByID("wnd[0]/usr/ssubSUB_SELECTION:SAPLHRPIQ00EVALOBJ_DIALOG:1400/ssubSUB_OBJECT:SAPLHRPIQ00EVALOBJ_DIALOG:1600/cntlCONTR_INST/shellcont/shell")

            ;; Load up module and insert new scheduled assessment
            userArea.FindByName('PIQEVALOBJ_HEADER-PARENT_OTYPE','GuiComboBox').Key := "SM"
            findTextElement(userArea,'PIQEVALOBJ_HEADER-PARENT_SHORT').text := this.module
            session.findById("wnd[0]").sendVKey(0)
            userArea.FindByName('PIQEVALOBJINST_SEL-PERYR','GuiComboBox').Key := "2024"
            userArea.FindByName('PIQEVALOBJINST_SEL-PERID','GuiComboBox').Key := this.semester
            userArea.FindByName('BT_SELECT','GuiButton').Press()

            for k, v in this.date {
                  gridView := session.findByID("wnd[0]/usr/ssubSUB_SELECTION:SAPLHRPIQ00EVALOBJ_DIALOG:1400/ssubSUB_OBJECT:SAPLHRPIQ00EVALOBJ_DIALOG:1600/cntlCONTR_INST/shellcont/shell")
                  gridView.pressToolbarButton("INSE")
                  
                  ;; Exam Date/Time
                  findTextElement(userArea,'PIQEVOBOFFER3_ATTR_DISP-EXAMDATE').text := v
                  findTextElement(userArea,'PIQEVOBOFFER3_ATTR_DISP-EXAMBEGTIME').text := this.time.start
                  findTextElement(userArea,'PIQEVOBOFFER3_ATTR_DISP-EXAMENDTIME').text := this.time.end
      
                  ;; Exam date published
                  userArea.FindByName('PIQEVOBOFFER3_ATTR_DISP-/ITED/EXAMDATE_PUBLISHED', 'GuiCheckBox').selected := 1
      
                  ;; Capacity
                  findTextElement(userArea,'PIQEVOBOFFER3_ATTR_DISP-CAPACITY').text := this.capacity.maximum
      
                  ;; Exam Location
                  findTextElement(userArea,'PIQEVOBOFFER3_ATTR_DISP-LOCATION_SHORT').setFocus()
                  findTextElement(userArea,'PIQEVOBOFFER3_ATTR_DISP-LOCATION_SHORT').text := this.location
                  session.findById("wnd[0]").sendVKey(4)
                  session.findById("wnd[1]/tbar[0]/btn[0]").press()

                  ;; Exam room
                  findTextElement(userArea,'PIQEVOBOFFER3_ATTR_DISP-ROOM_SHORT').setFocus()
                  session.findById("wnd[0]").sendVKey(4)
                  findTextElement(session.findByID("wnd[1]/usr"),'G_SELFLD_TAB-LOW').text := this.room
                  session.findById("wnd[1]/tbar[0]/btn[0]").press()
                  session.findById("wnd[1]/tbar[0]/btn[0]").press()
      
                  ;; Periods/Deadlines
                  findTextElement(userArea,'PIQEVOBOFFER_DISP-REGIS_BEGIN').text := this.registration.start
                  findTextElement(userArea,'PIQEVOBOFFER_DISP-REGIS_END').text := this.registration.end
                  findTextElement(userArea,'PIQEVOBOFFER_DISP-DEREG_END').text := this.registration.withdrawal
                  findTextElement(userArea,'PIQEVOBOFFER_DISP-/ITED/MARK_ENTRY_DEADLINE').text := this.registration.feedback
      
                  ;; Exam profile (stupid value help popup)
                  userArea.FindByName('EVOBJ_INST_DATA_FC2','GuiTab').Select()
                  session.findById("wnd[1]/tbar[0]/btn[0]").press()
                  try session.findById("wnd[1]/tbar[0]/btn[0]").press()
                  userArea.FindByName('PIQEXAMPROFILE_DISP-EXAMMODE','GuiComboBox').Key := this.examMode
                  findTextElement(userArea,'PIQEXAMPROFILE_DISP-DURATION').text := "1"
                  userArea.FindByName('PIQEXAMPROFILE_DISP-DURUNIT','GuiComboBox').Key := "HRS"
                  userArea.FindByName('PIQEVOBOFFER2_ATTR_TC_DISP-ACTIVITY','GuiComboBox').Key := "EX03"
                  findTextElement(userArea,'PIQEVOBOFFER2_ATTR_TC_DISP-OTYPE').text := "P"
                  findTextElement(userArea,'PIQEVOBOFFER2_ATTR_TC_DISP-SHORT').text := this.person
      
                  session.findById("wnd[0]").sendVKey(11)
                  session.findById("wnd[0]").sendVKey(3)
            }
            

      }




}