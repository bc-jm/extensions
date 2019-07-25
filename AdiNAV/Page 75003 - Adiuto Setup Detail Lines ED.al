page 75003 "Adiuto Setup Detail Lines ED"
{
    // version ADI.003

    Caption = 'Adiuto Setup Detail Lines';
    PageType = List;
    SourceTable = "Adiuto Setup Detail Lines ED";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Primary Key"; "Primary Key")
                {
                    Visible = false;
                }
                field("Line No."; "Line No.")
                {
                    Visible = false;
                }
                field("NAV Field Id"; "NAV Field Id")
                {

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        lRecField: Record "Field";
                        lPagFieldList: Page "Field List";
                    begin
                        lRecField.SETRANGE(TableNo, GetNavTableId);
                        lRecField.SETFILTER(Class, '<>%1', lRecField.Class::FlowFilter);
                        lPagFieldList.SETTABLEVIEW(lRecField);
                        lPagFieldList.LOOKUPMODE(TRUE);
                        IF lPagFieldList.RUNMODAL = ACTION::LookupOK THEN BEGIN
                            lPagFieldList.GETRECORD(lRecField);
                            VALIDATE("NAV Field Id", lRecField."No.");
                            VALIDATE("NAV Field Name", lRecField.FieldName);
                        END;
                    end;

                    trigger OnValidate()
                    begin
                        CurrPage.UPDATE(TRUE);
                    end;
                }
                field("NAV Field Name"; "NAV Field Name")
                {
                    Editable = gBlnEditable;
                }
                field("Adiuto Field Id"; "Adiuto Field Id")
                {
                    AssistEdit = true;

                    trigger OnAssistEdit()
                    var
                        lRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED";
                        lPagAdiutoFamilyList: Page "Adiuto Family List ED";
                        lIntAdiutoFamilyId: Integer;
                        contTxtErrorFamilyId: Label 'Adiuto Familiy not selected';
                    begin

                        //>AB20180706
                        lIntAdiutoFamilyId := GetAdiutoFamilyId;
                        IF lIntAdiutoFamilyId = 0 THEN
                            ERROR(contTxtErrorFamilyId);

                        lPagAdiutoFamilyList.SetFamily(lIntAdiutoFamilyId);
                        lPagAdiutoFamilyList.EDITABLE(FALSE);
                        lPagAdiutoFamilyList.LOOKUPMODE(TRUE);
                        IF lPagAdiutoFamilyList.RUNMODAL = ACTION::LookupOK THEN BEGIN
                            lPagAdiutoFamilyList.GetFieldValues("Adiuto Field Id", "Adiuto Field Name");
                            MODIFY;
                        END;
                        //<AB20180706
                    end;
                }
                field("Adiuto Field Name"; "Adiuto Field Name")
                {
                    Editable = gBlnEditable;
                }
                field("Use for Searching"; "Use for Searching")
                {
                }
                field("Use for Insertion"; "Use for Insertion")
                {
                }
                field("Use for Update"; "Use for Update")
                {
                }
                field("Decimal Separator"; "Decimal Separator")
                {
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action("Set editable Flowfield")
            {
                Caption = 'Set editable Flowfield';
                Image = Column;
                Visible = false;

                trigger OnAction()
                begin
                    gBlnEditable := NOT gBlnEditable;
                end;
            }
        }
    }

    trigger OnInit()
    begin
        gBlnEditable := FALSE;
    end;

    trigger OnOpenPage()
    begin
        gBlnEditable := FALSE;
    end;

    var
        gBlnEditable: Boolean;
}

