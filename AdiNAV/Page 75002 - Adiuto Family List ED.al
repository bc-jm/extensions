page 75002 "Adiuto Family List ED"
{
    // version ADI.003

    Caption = 'Adiuto Family/Field List';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Adiuto Setup Detail ED";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Caption = 'Lista';
                field(Description; Description)
                {
                }
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    begin
        gIntFamilyId := 0;
    end;

    trigger OnOpenPage()
    begin
        IF gOptTypeAdiutoNav = gOptTypeAdiutoNav::Adiuto THEN BEGIN
            GetFamilies;
        END;

        SETCURRENTKEY(Description);
    end;

    var
        gIntFamilyId: Integer;
        gOptTypeAdiutoNav: Option Adiuto,NAV;

    procedure SetAdiutoNav(pOptTypeAdiutoNav: Option Adiuto,NAV)
    begin
        gOptTypeAdiutoNav := pOptTypeAdiutoNav;
    end;

    procedure SetFamily(pIntFamilyId: Integer)
    begin
        gIntFamilyId := pIntFamilyId;
    end;

    local procedure GetFamilies()
    var
        lCduAdiutoNetWebService: Codeunit "Adiuto Net Web Service ED";
        lTxtXml: Text;
        lCduXMLBufferWriter: Codeunit "XML Buffer Writer";
        lRecXMLBuffer: Record "XML Buffer";
        lPagAdiutoFamilyList: Page "Adiuto Family List ED";
    begin
        DELETEALL;
        lCduAdiutoNetWebService.GetXmlFamsObject(TRUE, Rec, gIntFamilyId);
        FINDFIRST;
    end;

    procedure GetFamilyValues(var pIntFamilyId: Integer; var pTxtFamilyDescription: Text; var pTxtDescription: Text)
    begin
        CurrPage.SETSELECTIONFILTER(Rec);
        IF Rec.FINDFIRST THEN BEGIN
            pIntFamilyId := "Id Family Document";
            pTxtFamilyDescription := "Name Family Document";
            pTxtDescription := "Name Family Document";
        END;
    end;

    procedure GetFieldValues(var pTxtFieldId: Integer; var pTxtFieldDescription: Text)
    begin
        CurrPage.SETSELECTIONFILTER(Rec);
        IF Rec.FINDFIRST THEN BEGIN
            pTxtFieldId := "Id Family Document"; //AB20180706
            pTxtFieldDescription := "Name Family Document"; //AB20180706
        END;
    end;

    procedure GetNavFamilies(var pRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED")
    var
    begin
        DELETEALL;

        IF pRecAdiutoSetupDetail.FINDSET THEN BEGIN
            REPEAT
                Rec := pRecAdiutoSetupDetail;
                INSERT;
            UNTIL pRecAdiutoSetupDetail.NEXT = 0;
        END;

        FINDFIRST;
    end;

    procedure GetNavSelectedRecord(var pRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED")
    begin
        pRecAdiutoSetupDetail.SETRANGE("Primary Key", "Primary Key");
        pRecAdiutoSetupDetail.SETRANGE("Table Id", "Table Id");
        pRecAdiutoSetupDetail.SETRANGE("Document Type", "Document Type");
        pRecAdiutoSetupDetail.SETRANGE("Id Family Document", "Id Family Document");
        pRecAdiutoSetupDetail.FIND('-');
    end;
}

