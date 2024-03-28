#Requires AutoHotkey v2.0 
#Include utils.ahk
TraySetIcon("rat.png")
mice := MiceGui()

Class MiceGui extends Gui{

      __New(){
            mice := Gui(,"Rats")
            mice.SetFont("s12")
            
            loop read "commands.txt" {
                  
                  this.%A_LoopReadLine% := mice.AddButton(,A_LoopReadLine)
                  this.%A_LoopReadLine%.OnEvent("click",clicked)
            }
                  
            mice.Show

            
      clicked(button, Info){
            %button.text%()
      }

      }

}

addCEInAcademicStructure(){
      session := sapActiveSession()
      selectedNode := academicStructureCreateChildNode(session,"CE","EX","Exam")

      userArea := session.findById("wnd[0]/usr")

      userArea.findByID("tabsD6100TS/tabp$$1/ssubS_INFTY_02:SAPLRHV6:7120/tabsD7120TS/tabpT7120_00/ssubD7120_SUBTYPE:SAPLRHV6:7125/cntlD7125TC/shellcont/shell").Text := selectedNode.Description " Exam"
      
      session.findById("wnd[0]/usr/tabsD6100TS/tabp$$2").select()
      
      userArea.findByName("P1766-AUDTYPE","GuiComboBox").key := "3000"
      userArea.findByName("P1766-EVOBTYPE","GuiComboBox").key := "TE"
      
      session.findById("wnd[0]/usr/tabsD6100TS/tabp$$3").select()
      
      userArea.findByName("P1767-EVALREPEATTYPE","GuiComboBox").key := "HCEX"
      userArea.findByName("P1767-SCALEID","GuiComboBox").key := "0-10"
      userArea.findByName("P1767-AGRTYPE","GuiComboBox").key := "600"
      
      session.findByID("wnd[0]/mbar/menu[0]/menu[5]").select()
}

addLectureInAcademicStructure(){
      session := sapActiveSession()

      selectedNode := academicStructureCreateChildNode(session,"D","LC","Lecture")

      userArea := session.findById("wnd[0]/usr")

      userArea.findByName("P1731-CATEGORY","GuiComboBox").key := "STD"
      userArea.findByName("P1731-METHOD","GuiComboBox").key := "HC"

      session.findById("wnd[0]/usr/tabsD6100TS/tabp$$2").select()
      
      findTextElement(userArea,"HRVPV6A-KAPZ1").Text := "1"
      findTextElement(userArea,"HRVPV6A-KAPZ2").Text := "999"
      findTextElement(userArea,"HRVPV6A-KAPZ3").Text := "999"

      session.findById("wnd[0]/usr/tabsD6100TS/tabp$$5").select()

      userArea.findByName("HRVPV6A-RELOBJSRK","GuiCTextField").Text := "7"

      session.findByID("wnd[0]/mbar/menu[0]/menu[5]").select()
}


addTutorialInAcademicStructure(){
      session := sapActiveSession()

      selectedNode := academicStructureCreateChildNode(session,"D","TU","Tutorial")

      userArea := session.findById("wnd[0]/usr")

      userArea.findByName("P1731-CATEGORY","GuiComboBox").key := "SEM"
      userArea.findByName("P1731-METHOD","GuiComboBox").key := "LG"
      userArea.findByName("P1731-ATTREQ","GuiCheckBox").selected := 1

      session.findById("wnd[0]/usr/tabsD6100TS/tabp$$2").select()
      
      findTextElement(userArea,"HRVPV6A-KAPZ1").Text := "1"
      findTextElement(userArea,"HRVPV6A-KAPZ2").Text := "999"
      findTextElement(userArea,"HRVPV6A-KAPZ3").Text := "999"

      session.findById("wnd[0]/usr/tabsD6100TS/tabp$$5").select()

      userArea.findByName("HRVPV6A-RELOBJSRK","GuiCTextField").Text := "7"

      session.findByID("wnd[0]/mbar/menu[0]/menu[5]").select()
}

addAllInAcademicStructure(){
      addCEInAcademicStructure()
      addLectureInAcademicStructure()
      addTutorialInAcademicStructure()
}