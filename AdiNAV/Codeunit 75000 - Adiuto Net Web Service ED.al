codeunit 75000 "Adiuto Net Web Service ED"
{
    // version ADI.003

    // ADI-001 2019.03.26
    //   added decimal separator fix
    // JM-FM20190429
    //   fix Xades parameter


    trigger OnRun()
    begin
        LoginSDKService;
        MESSAGE(gIdSessionSDKService);
        LogoutSDKService;
    end;

    var
        Text001: Label 'Login failure';
        Text002: Label 'Adiuto Setup not set';
        gIdSessionAdijedWS: Text[50];
        gIdSessionSDKService: Text[50];
        gRecAdiutoSetup: Record "Adiuto Setup ED";
        gStrError: Text;
        Text003: Label 'document modify on Adiuto Failed';
        Text004: Label 'document insert on Adiuto Failed';
        Text005: Label 'Document Delete on Adiuto Failed';
        Text006: Label 'Get document ID failed';

    [TryFunction]
    local procedure CallRESTWebService(var Parameters: DotNet SortedDictionary_Of_T_U; var HttpResponseMessage: DotNet HttpResponseMessage)
    var
        HttpClient: DotNet HttpClient;
        HttpContent: DotNet HttpContent;
        Uri: DotNet Uri;
        Encoding: DotNet Encoding;
        bytes: DotNet Array;
        AuthHeaderValue: DotNet AuthenticationHeaderValue;
        Convert: DotNet Convert;
        test: Text;
        bytesarray: Char;
        StringContent: DotNet StringContent;
    begin
        HttpClient := HttpClient.HttpClient();
        HttpClient.BaseAddress := Uri.Uri(FORMAT(Parameters.Item('baseurl')));

        IF Parameters.ContainsKey('SOAPAction') THEN
            HttpClient.DefaultRequestHeaders.Add('SOAPAction', FORMAT(Parameters.Item('SOAPAction')));

        IF Parameters.ContainsKey('username') THEN BEGIN
            bytes := Encoding.ASCII.GetBytes(STRSUBSTNO('%1:%2', FORMAT(Parameters.Item('username')), FORMAT(Parameters.Item('password'))));
            AuthHeaderValue := AuthHeaderValue.AuthenticationHeaderValue('Basic', Convert.ToBase64String(bytes));
            HttpClient.DefaultRequestHeaders.Authorization := AuthHeaderValue;
        END;

        IF Parameters.ContainsKey('httpcontent') THEN
            HttpContent := StringContent.StringContent(FORMAT(Parameters.Item('httpcontent')));

        /*
        IF NOT ISNULL(HttpContent) AND Parameters.ContainsKey('ContentType') THEN BEGIN
          HttpContent.Headers.Remove('Content-Type'));
          HttpContent.Headers.Add('Content-Type',FORMAT(Parameters.Item('ContentType')));
        END;
        */

        CASE FORMAT(Parameters.Item('restmethod')) OF
            'GET':
                HttpResponseMessage := HttpClient.GetAsync(FORMAT(Parameters.Item('path'))).Result;
            'POST':
                HttpResponseMessage := HttpClient.PostAsync(FORMAT(Parameters.Item('path')), HttpContent).Result;
            'PUT':
                HttpResponseMessage := HttpClient.PutAsync(FORMAT(Parameters.Item('path')), HttpContent).Result;
            'DELETE':
                HttpResponseMessage := HttpClient.DeleteAsync(FORMAT(Parameters.Item('path'))).Result;
        END;

        HttpResponseMessage.EnsureSuccessStatusCode(); // Throws an error when no success

    end;

    procedure LoginAdijedWS()
    var
        Parameters: DotNet SortedDictionary_Of_T_U;
        HttpResponseMessage: DotNet HttpResponseMessage;
        StringContent: DotNet StringContent;
        lTxtXML: Text;
        lCduXMLBufferWriter: Codeunit "XML Buffer Writer";
        lRecXMLBuffer: Record "XML Buffer";
    begin
        IF NOT gRecAdiutoSetup.GET THEN
            ERROR(Text002);

        Parameters := Parameters.SortedDictionary();
        Parameters.Add('baseurl', 'http://' + gRecAdiutoSetup."Ip Address" + ':' + FORMAT(gRecAdiutoSetup.Port));
        Parameters.Add('path', '/adiJed/services/AdiJedWS');
        Parameters.Add('restmethod', 'POST');
        Parameters.Add('ContentType', 'text/xml; charset=utf-8');
        Parameters.Add('SOAPAction', 'remoteLogin');
        Parameters.Add('httpcontent',
                     '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">' +
                     '<soap:Body><remoteLogin xmlns="urn:' + gRecAdiutoSetup."Ip Address" + ':' + FORMAT(gRecAdiutoSetup.Port) + '/adiJed/AdiJedWS/remoteLogin">' + //+ ':' + FORMAT(gRecAdiutoSetup.Port)
                     '<username>' + gRecAdiutoSetup.User + '</username><password>' + gRecAdiutoSetup.Password + '</password>' +
                     '</remoteLogin></soap:Body></soap:Envelope>');
        // Parameters.Add('username',gRecAdiutoSetup.User);
        // Parameters.Add('password',gRecAdiutoSetup.Password);

        CallRESTWebService(Parameters, HttpResponseMessage);

        lTxtXML := HttpResponseMessage.Content.ReadAsStringAsync.Result;
        lCduXMLBufferWriter.InitializeXMLBufferFromText(lRecXMLBuffer, lTxtXML);
        lRecXMLBuffer.SETRANGE(Type, lRecXMLBuffer.Type::Element);
        lRecXMLBuffer.SETRANGE(Name, 'loginResult');
        IF lRecXMLBuffer.FIND('-') THEN
            gIdSessionAdijedWS := lRecXMLBuffer.Value;
    end;

    local procedure LogoutAdijedWS()
    var
        Parameters: DotNet SortedDictionary_Of_T_U;
        HttpResponseMessage: DotNet HttpResponseMessage;
        StringContent: DotNet StringContent;
        lTxtXML: Text;
    begin
        IF NOT gRecAdiutoSetup.GET THEN
            ERROR(Text002);

        Parameters := Parameters.SortedDictionary();
        Parameters.Add('baseurl', 'http://' + gRecAdiutoSetup."Ip Address" + ':' + FORMAT(gRecAdiutoSetup.Port));
        Parameters.Add('path', '/adiJed/services/AdiJedWS');
        Parameters.Add('restmethod', 'POST');
        Parameters.Add('ContentType', 'text/xml; charset=utf-8');
        Parameters.Add('SOAPAction', 'remoteLogout');
        Parameters.Add('httpcontent',
                     '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">' +
                     '<soap:Body><remoteLogout xmlns="urn:' + gRecAdiutoSetup."Ip Address" + ':' + FORMAT(gRecAdiutoSetup.Port) + '/adiJed/AdiJedWS/remoteLogout">' +
                     '<sessionId>' + gIdSessionAdijedWS + '</sessionId>' +
                     '</remoteLogout></soap:Body></soap:Envelope>');
        // Parameters.Add('username',gRecAdiutoSetup.User);
        // Parameters.Add('password',gRecAdiutoSetup.Password);

        CallRESTWebService(Parameters, HttpResponseMessage);
        gIdSessionAdijedWS := '';
    end;

    procedure LoginSDKService()
    var
        Parameters: DotNet SortedDictionary_Of_T_U;
        HttpResponseMessage: DotNet HttpResponseMessage;
        StringContent: DotNet StringContent;
        lTxtXML: Text;
        lCduXMLBufferWriter: Codeunit "XML Buffer Writer";
        lRecXMLBuffer: Record "XML Buffer";
    begin
        IF NOT gRecAdiutoSetup.GET THEN
            ERROR(Text002);

        Parameters := Parameters.SortedDictionary();
        Parameters.Add('baseurl', 'http://' + gRecAdiutoSetup."Ip Address" + ':' + FORMAT(gRecAdiutoSetup.Port));
        Parameters.Add('path', '/adiJed/services/SDKService');
        Parameters.Add('restmethod', 'POST');
        Parameters.Add('ContentType', 'text/xml; charset=utf-8');
        Parameters.Add('SOAPAction', 'remoteLogin');
        Parameters.Add('httpcontent',
                     '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">' +
                     '<soap:Body><remoteLogin xmlns="urn:' + gRecAdiutoSetup."Ip Address" + ':' + FORMAT(gRecAdiutoSetup.Port) + '/adiJed/SDKService/remoteLogin">' + //+ ':' + FORMAT(gRecAdiutoSetup.Port)
                     '<username>' + gRecAdiutoSetup.User + '</username><password>' + gRecAdiutoSetup.Password + '</password>' +
                     '</remoteLogin></soap:Body></soap:Envelope>');

        CallRESTWebService(Parameters, HttpResponseMessage);

        lTxtXML := HttpResponseMessage.Content.ReadAsStringAsync.Result;
        lCduXMLBufferWriter.InitializeXMLBufferFromText(lRecXMLBuffer, lTxtXML);
        lRecXMLBuffer.SETRANGE(Type, lRecXMLBuffer.Type::Element);
        lRecXMLBuffer.SETRANGE(Name, 'loginResult');
        IF lRecXMLBuffer.FIND('-') THEN
            gIdSessionSDKService := lRecXMLBuffer.Value;
    end;

    local procedure LogoutSDKService()
    var
        Parameters: DotNet SortedDictionary_Of_T_U;
        HttpResponseMessage: DotNet HttpResponseMessage;
        StringContent: DotNet StringContent;
        lTxtXML: Text;
    begin
        IF NOT gRecAdiutoSetup.GET THEN
            ERROR(Text002);

        Parameters := Parameters.SortedDictionary();
        Parameters.Add('baseurl', 'http://' + gRecAdiutoSetup."Ip Address" + ':' + FORMAT(gRecAdiutoSetup.Port));
        Parameters.Add('path', '/adiJed/services/SDKService');
        Parameters.Add('restmethod', 'POST');
        Parameters.Add('ContentType', 'text/xml; charset=utf-8');
        Parameters.Add('SOAPAction', 'remoteLogout');
        Parameters.Add('httpcontent',
                     '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">' +
                     '<soap:Body><remoteLogout xmlns="urn:' + gRecAdiutoSetup."Ip Address" + ':' + FORMAT(gRecAdiutoSetup.Port) + '/adiJed/SDKService/remoteLogout">' +
                     '<sessionId>' + gIdSessionSDKService + '</sessionId>' +
                     '</remoteLogout></soap:Body></soap:Envelope>');

        CallRESTWebService(Parameters, HttpResponseMessage);
        gIdSessionSDKService := '';
    end;

    procedure GetDocument(pRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED"; pRefRecord: RecordRef; pTxtFileExtension: Text) Result: Text
    var
        lIntNumFields: Integer;
        lIntIndex: Integer;
        lIntIdDoc: Integer;
        Parameters: DotNet SortedDictionary_Of_T_U;
        lTxtContent: Text;
        HttpResponseMessage: DotNet HttpResponseMessage;
    begin
        gStrError := GetDocId(pRecAdiutoSetupDetail, pRefRecord);
        EVALUATE(lIntIdDoc, gStrError);
        EXIT(GetLargeContent(lIntIdDoc, pTxtFileExtension));
    end;

    procedure GetLargeContent(pIntIdDocAdiuto: Integer; pTxtFileExtension: Text) Return: Text
    var
        Convert: DotNet Convert;
        ClientFile: DotNet File;
        FileArray: DotNet Array;
        ClientStream: DotNet FileStream;
        FileMode: DotNet FileMode;
        lTxtXmlToSend: BigText;
        lIntNumFields: Integer;
        lIntIndex: Integer;
        lCduFileManagement: Codeunit "File Management";
        lFile: File;
        lOutStream: OutStream;
        bEndFile: Boolean;
        lInStream: InStream;
        lTxtBase64: BigText;
        lBlnEOF: Boolean;
        lIntNumDwl: Integer;
        lTxtEndBase64: Text;
        ByteArray: DotNet Array;
        lTxtFileName: Text;
        Parameters: DotNet SortedDictionary_Of_T_U;
        HttpResponseMessage: DotNet HttpResponseMessage;
        lTxtXML: Text;
        XmlDoc: Codeunit "XML DOM Management";
        HttpContent: DotNet HttpContent;
        XmlNodeChild: DotNet XmlNode;
        XmlDocument: DotNet XmlDocument;
        XmlNode: DotNet XmlNode;
        XmlNodeList: DotNet XmlNodeList;
        lBlnLoop: Boolean;
        lTxtEnveloperXML: Text;
    begin
        lTxtFileName := lCduFileManagement.ServerTempFileName(pTxtFileExtension);
        IF EXISTS(lTxtFileName) THEN
            IF NOT ERASE(lTxtFileName) THEN
                ERROR('Impossibile eliminare il file "' + lTxtFileName + '"');

        LoginSDKService;

        lIntNumDwl := 1;
        lBlnEOF := FALSE;
        Parameters := Parameters.SortedDictionary();

        REPEAT
            IF Parameters.Count > 0 THEN
                Parameters.Clear;

            Parameters.Add('baseurl', 'http://' + gRecAdiutoSetup."Ip Address" + ':' + FORMAT(gRecAdiutoSetup.Port));
            Parameters.Add('path', '/adiJed/services/SDKService');
            Parameters.Add('restmethod', 'POST');
            Parameters.Add('ContentType', 'text/xml; charset=utf-8');
            Parameters.Add('SOAPAction', 'getLargeContent2');
            Parameters.Add('httpcontent', '<soap:Envelope xmlns:ns1="http://xfire.sdk" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
                                  '<soap:Header/><soap:Body><ns1:getLargeContent2>' +
                                  '<ns1:session-id>' + gIdSessionSDKService + '</ns1:session-id>' +
                                  '<ns1:idunivoco>' + FORMAT(pIntIdDocAdiuto) + '</ns1:idunivoco>' +
                                  '<ns1:dim>1</ns1:dim>' +
                                  '</ns1:getLargeContent2></soap:Body></soap:Envelope>');

            CallRESTWebService(Parameters, HttpResponseMessage);
            lTxtEnveloperXML := HttpResponseMessage.Content.ReadAsStringAsync.Result;
            IF HttpResponseMessage.StatusCode <> 200 THEN BEGIN
                LogoutSDKService;
                ERROR('Http Error ' + ' ' + FORMAT(HttpResponseMessage.StatusCode) + ': ' + lTxtXML);
            END;

            XmlDoc.LoadXMLDocumentFromText(lTxtEnveloperXML, XmlDocument);
            lTxtXML := '';
            lBlnLoop := TRUE;
            REPEAT
                lTxtXML := FORMAT(XmlDocument.Value);
                XmlDocument := XmlDocument.FirstChild;
                IF ISNULL(XmlDocument) = TRUE THEN
                    lBlnLoop := FALSE;
            UNTIL lBlnLoop = FALSE;

            lTxtEndBase64 := lTxtXML;
            IF lTxtEndBase64 = 'AA==' THEN
                lBlnEOF := TRUE
            ELSE BEGIN
                CLEAR(lTxtBase64);
                lTxtBase64.ADDTEXT(lTxtEndBase64);
                //lo salva sul server!!!
                IF ISNULL(ClientStream) THEN
                    ClientStream := ClientStream.FileStream(lTxtFileName, FileMode.Append);

                ByteArray := Convert.FromBase64String(lTxtBase64);
                ClientStream.Write(ByteArray, 0, ByteArray.Length);
                ClientStream.Close;
                CLEAR(ClientStream);
            END;
            lIntNumDwl := lIntNumDwl + 1;
        UNTIL lBlnEOF = TRUE;

        LogoutSDKService;
        Return := lTxtFileName;
    end;

    procedure GetLargeContentExt(pIntIdDocAdiuto: Integer; pTxtFileExtension: Text) Return: Text
    var
        Convert: DotNet Convert;
        ClientFile: DotNet File;
        FileArray: DotNet Array;
        ClientStream: DotNet FileStream;
        FileMode: DotNet FileMode;
        lTxtXmlToSend: BigText;
        lIntNumFields: Integer;
        lIntIndex: Integer;
        lCduFileManagement: Codeunit "File Management";
        lFile: File;
        lOutStream: OutStream;
        bEndFile: Boolean;
        lInStream: InStream;
        lTxtBase64: BigText;
        lBlnEOF: Boolean;
        lIntNumDwl: Integer;
        lTxtEndBase64: Text;
        ByteArray: DotNet Array;
        lTxtFileName: Text;
        Parameters: DotNet SortedDictionary_Of_T_U;
        HttpResponseMessage: DotNet HttpResponseMessage;
        lTxtXML: Text;
        XmlDoc: Codeunit "XML DOM Management";
        HttpContent: DotNet HttpContent;
        XmlNodeChild: DotNet XmlNode;
        XmlDocument: DotNet XmlDocument;
        XmlNode: DotNet XmlNode;
        XmlNodeList: DotNet XmlNodeList;
        lBlnLoop: Boolean;
        lTxtEnveloperXML: Text;
    begin
        lTxtFileName := lCduFileManagement.ServerTempFileName(pTxtFileExtension);
        IF EXISTS(lTxtFileName) THEN
            IF NOT ERASE(lTxtFileName) THEN
                ERROR('Impossibile eliminare il file "' + lTxtFileName + '"');

        LoginSDKService;

        lIntNumDwl := 1;
        lBlnEOF := FALSE;
        Parameters := Parameters.SortedDictionary();

        REPEAT
            IF Parameters.Count > 0 THEN
                Parameters.Clear;

            Parameters.Add('baseurl', 'http://' + gRecAdiutoSetup."Ip Address" + ':' + FORMAT(gRecAdiutoSetup.Port));
            Parameters.Add('path', '/adiJed/services/SDKService');
            Parameters.Add('restmethod', 'POST');
            Parameters.Add('ContentType', 'text/xml; charset=utf-8');
            Parameters.Add('SOAPAction', 'getLargeContentExt');
            Parameters.Add('httpcontent', '<soap:Envelope xmlns:ns1="http://xfire.sdk" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
                                  '<soap:Header/><soap:Body><ns1:getLargeContentExt>' +
                                  '<ns1:session-id>' + gIdSessionSDKService + '</ns1:session-id>' +
                                  '<ns1:idunivoco>' + FORMAT(pIntIdDocAdiuto) + '</ns1:idunivoco>' +
                                  '<ns1:extRequest>' + '.' + pTxtFileExtension + '</ns1:extRequest>' +
                                  '</ns1:getLargeContentExt></soap:Body></soap:Envelope>');

            CallRESTWebService(Parameters, HttpResponseMessage);
            lTxtEnveloperXML := HttpResponseMessage.Content.ReadAsStringAsync.Result;
            IF HttpResponseMessage.StatusCode <> 200 THEN BEGIN
                LogoutSDKService;
                ERROR('Http Error ' + ' ' + FORMAT(HttpResponseMessage.StatusCode) + ': ' + lTxtXML);
            END;

            XmlDoc.LoadXMLDocumentFromText(lTxtEnveloperXML, XmlDocument);
            lTxtXML := '';
            lBlnLoop := TRUE;
            REPEAT
                lTxtXML := FORMAT(XmlDocument.Value);
                XmlDocument := XmlDocument.FirstChild;
                IF ISNULL(XmlDocument) = TRUE THEN
                    lBlnLoop := FALSE;
            UNTIL lBlnLoop = FALSE;

            lTxtEndBase64 := lTxtXML;
            IF lTxtEndBase64 = 'AA==' THEN
                lBlnEOF := TRUE
            ELSE BEGIN
                CLEAR(lTxtBase64);
                lTxtBase64.ADDTEXT(lTxtEndBase64);
                //lo salva sul server!!!
                IF ISNULL(ClientStream) THEN
                    ClientStream := ClientStream.FileStream(lTxtFileName, FileMode.Append);

                ByteArray := Convert.FromBase64String(lTxtBase64);
                ClientStream.Write(ByteArray, 0, ByteArray.Length);
                ClientStream.Close;
                CLEAR(ClientStream);
            END;
            lIntNumDwl := lIntNumDwl + 1;
        UNTIL lBlnEOF = TRUE;

        LogoutSDKService;
        Return := lTxtFileName;
    end;

    procedure GetLargeContentXades(pIntIdDocAdiuto: Integer; pTxtFileExtension: Text; pTxtXades: Text; pTxtAttach: Text) Return: Text
    var
        Convert: DotNet Convert;
        ClientFile: DotNet File;
        FileArray: DotNet Array;
        ClientStream: DotNet FileStream;
        FileMode: DotNet FileMode;
        lTxtXmlToSend: BigText;
        lIntNumFields: Integer;
        lIntIndex: Integer;
        lCduFileManagement: Codeunit "File Management";
        lFile: File;
        lOutStream: OutStream;
        bEndFile: Boolean;
        lInStream: InStream;
        lTxtBase64: BigText;
        lBlnEOF: Boolean;
        lIntNumDwl: Integer;
        lTxtEndBase64: Text;
        ByteArray: DotNet Array;
        lTxtFileName: Text;
        Parameters: DotNet SortedDictionary_Of_T_U;
        HttpResponseMessage: DotNet HttpResponseMessage;
        lTxtXML: Text;
        XmlDoc: Codeunit "XML DOM Management";
        HttpContent: DotNet HttpContent;
        XmlNodeChild: DotNet XmlNode;
        XmlDocument: DotNet XmlDocument;
        XmlNode: DotNet XmlNode;
        XmlNodeList: DotNet XmlNodeList;
        lBlnLoop: Boolean;
        lTxtEnveloperXML: Text;
    begin
        lTxtFileName := lCduFileManagement.ServerTempFileName(pTxtFileExtension);
        IF EXISTS(lTxtFileName) THEN
            IF NOT ERASE(lTxtFileName) THEN
                ERROR('Impossibile eliminare il file "' + lTxtFileName + '"');

        LoginSDKService;

        lIntNumDwl := 1;
        lBlnEOF := FALSE;
        Parameters := Parameters.SortedDictionary();

        REPEAT
            IF Parameters.Count > 0 THEN
                Parameters.Clear;

            Parameters.Add('baseurl', 'http://' + gRecAdiutoSetup."Ip Address" + ':' + FORMAT(gRecAdiutoSetup.Port));
            Parameters.Add('path', '/adiJed/services/SDKService');
            Parameters.Add('restmethod', 'POST');
            Parameters.Add('ContentType', 'text/xml; charset=utf-8');
            Parameters.Add('SOAPAction', 'getLargeContentXades');
            Parameters.Add('httpcontent', '<soap:Envelope xmlns:ns1="http://xfire.sdk" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
                                  '<soap:Header/><soap:Body><ns1:getLargeContentXades>' +
                                  '<ns1:session-id>' + gIdSessionSDKService + '</ns1:session-id>' +
                                  '<ns1:idunivoco>' + FORMAT(pIntIdDocAdiuto) + '</ns1:idunivoco>' +
                                  '<ns1:extRequest>' + '.' + pTxtFileExtension + '</ns1:extRequest>' +
                                  '<ns1:getXades>' + pTxtXades + '</ns1:getXades>' +
                                  //>JM-FM20190429
                                  '<ns1:getAttach>' + pTxtAttach + '</ns1:getAttach>' +
                                  //<JM-FM20190429
                                  '</ns1:getLargeContentXades></soap:Body></soap:Envelope>');

            CallRESTWebService(Parameters, HttpResponseMessage);
            lTxtEnveloperXML := HttpResponseMessage.Content.ReadAsStringAsync.Result;
            IF HttpResponseMessage.StatusCode <> 200 THEN BEGIN
                LogoutSDKService;
                ERROR('Http Error ' + ' ' + FORMAT(HttpResponseMessage.StatusCode) + ': ' + lTxtXML);
            END;

            XmlDoc.LoadXMLDocumentFromText(lTxtEnveloperXML, XmlDocument);
            lTxtXML := '';
            lBlnLoop := TRUE;
            REPEAT
                lTxtXML := FORMAT(XmlDocument.Value);
                XmlDocument := XmlDocument.FirstChild;
                IF ISNULL(XmlDocument) = TRUE THEN
                    lBlnLoop := FALSE;
            UNTIL lBlnLoop = FALSE;

            lTxtEndBase64 := lTxtXML;
            IF lTxtEndBase64 = 'AA==' THEN
                lBlnEOF := TRUE
            ELSE BEGIN
                CLEAR(lTxtBase64);
                lTxtBase64.ADDTEXT(lTxtEndBase64);
                //lo salva sul server!!!
                IF ISNULL(ClientStream) THEN
                    ClientStream := ClientStream.FileStream(lTxtFileName, FileMode.Append);

                ByteArray := Convert.FromBase64String(lTxtBase64);
                ClientStream.Write(ByteArray, 0, ByteArray.Length);
                ClientStream.Close;
                CLEAR(ClientStream);
            END;
            lIntNumDwl := lIntNumDwl + 1;
        UNTIL lBlnEOF = TRUE;

        LogoutSDKService;
        Return := lTxtFileName;
    end;

    local procedure GetXmlFams(pBlnLoginLogout: Boolean): Text
    var
        Parameters: DotNet SortedDictionary_Of_T_U;
        lTxtContent: Text;
        HttpResponseMessage: DotNet HttpResponseMessage;
        lTxtEnvelopeXML: Text;
        lTxtXML: Text;
        XmlNode: DotNet XmlNode;
        XmlNodeList: DotNet XmlNodeList;
        XmlNodeChild: DotNet XmlNode;
        lIntIndex: Integer;
        XmlDocument: DotNet XmlDocument;
        XmlNSM: DotNet XmlNamespaceManager;
        XmlNameTable: DotNet XmlNameTable;
        out: OutStream;
        MyFile: File;
        blnLoop: Boolean;
        XmlDocumentChild: DotNet XmlDocument;
        XmlDocChild: Codeunit "XML DOM Management";
        XmlDoc: Codeunit "XML DOM Management";
    begin
        IF gIdSessionAdijedWS = '' THEN
            LoginAdijedWS;

        Parameters := Parameters.SortedDictionary();
        Parameters.Add('baseurl', 'http://' + gRecAdiutoSetup."Ip Address" + ':' + FORMAT(gRecAdiutoSetup.Port));
        Parameters.Add('path', '/adiJed/services/AdiJedWS');
        Parameters.Add('restmethod', 'POST');
        Parameters.Add('ContentType', 'text/xml; charset=utf-8');
        Parameters.Add('SOAPAction', 'getFams');

        lTxtContent := '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
                       '<soap:Body><ns1:getFams1 xmlns:ns1="http://ws.adiJed">' +
                       '<ns1:session-id>' + gIdSessionAdijedWS + '</ns1:session-id>' +
                       '<ns1:auth>' + gRecAdiutoSetup.User + '</ns1:auth>' +
                       '</ns1:getFams1></soap:Body></soap:Envelope>';

        Parameters.Add('httpcontent', lTxtContent);

        CallRESTWebService(Parameters, HttpResponseMessage);
        lTxtEnvelopeXML := HttpResponseMessage.Content.ReadAsStringAsync.Result;
        IF HttpResponseMessage.StatusCode <> 200 THEN BEGIN
            LogoutAdijedWS;
            ERROR('Http Error ' + ' ' + FORMAT(HttpResponseMessage.StatusCode) + ': ' + lTxtEnvelopeXML);
        END;

        XmlDoc.LoadXMLDocumentFromText(lTxtEnvelopeXML, XmlDocument);

        XmlDocument := XmlDocument.FirstChild;
        XmlNodeList := XmlDocument.GetElementsByTagName('ns1:families');

        lTxtXML := '';
        IF XmlNodeList.Count > 0 THEN BEGIN
            FOR lIntIndex := 0 TO XmlNodeList.Count DO BEGIN
                XmlNode := XmlNodeList.Item(lIntIndex);

                IF ISNULL(XmlNode) = FALSE THEN BEGIN
                    XmlNodeChild := XmlNode.FirstChild;
                    IF ISNULL(XmlNodeChild) = FALSE THEN BEGIN
                        //MESSAGE(XmlNodeChild.Name + ': ' + XmlNodeChild.Value);
                        lTxtXML := XmlNodeChild.Value;
                        //XmlDoc.LoadXMLDocumentFromText(XmlNodeChild.Value, XmlDocumentChild);
                        //MyFile.CREATE('C:\Temp\getfams.xml');
                        //MyFile.CREATEOUTSTREAM(out);
                        //XmlDocChild.SaveXMLDocumentToOutStream(out,XmlDocumentChild);
                        //MyFile.CLOSE;
                    END;
                END;
            END;
        END;

        IF pBlnLoginLogout THEN
            LogoutAdijedWS;

        EXIT(lTxtXML);
    end;

    procedure GetXmlFamsObject(pBlnLoginLogout: Boolean; var pRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED" temporary; pIntFamilyId: Integer)
    var
        lTxtFamilyDescription: Text;
        lIntFamilyId: Integer;
        lTxtXML: Text;
        XmlNodeList: DotNet XmlNodeList;
        XmlAttributes: DotNet XmlAttributeCollection;
        XmlDocument: DotNet XmlDocument;
        XmlNSM: DotNet XmlNamespaceManager;
        XmlNameTable: DotNet XmlNameTable;
        out: OutStream;
        MyFile: File;
        blnLoop: Boolean;
        XmlDocumentChild: DotNet XmlDocument;
        XmlDocChild: Codeunit "XML DOM Management";
        XmlDoc: Codeunit "XML DOM Management";
        lPagAdiutoFamilyList: Page "Adiuto Family List ED";
        XmlNodeListChild: DotNet XmlNodeList;
        XmlNodeChild: DotNet XmlNode;
        XmlNode: DotNet XmlNode;
        lIntIndexChild: Integer;
        lIntIndex: Integer;
        XmlNodeListChildFields: DotNet XmlNodeList;
        lIntIndexChildFields: Integer;
        XmlNodeChildField: DotNet XmlNode;
        lIntId: Integer;
        lTxtNameGetField: Text;
    begin
        lTxtXML := GetXmlFams(pBlnLoginLogout);
        IF lTxtXML <> '' THEN BEGIN
            XmlDoc.LoadXMLDocumentFromText(lTxtXML, XmlDocument);
            XmlNodeList := XmlDocument.GetElementsByTagName('famiglia');

            IF XmlNodeList.Count > 0 THEN BEGIN
                FOR lIntIndex := 0 TO (XmlNodeList.Count - 1) DO BEGIN
                    XmlNode := XmlNodeList.Item(lIntIndex);
                    IF ISNULL(XmlNode) = FALSE THEN BEGIN
                        XmlAttributes := XmlNode.Attributes;
                        lTxtFamilyDescription := XmlAttributes.GetNamedItem('id').Value;
                        EVALUATE(lIntFamilyId, lTxtFamilyDescription);
                        lTxtFamilyDescription := XmlAttributes.GetNamedItem('nome').Value;
                        IF (pIntFamilyId = 0) THEN BEGIN
                            IF NOT pRecAdiutoSetupDetail.GET('', lIntFamilyId) THEN BEGIN
                                pRecAdiutoSetupDetail.INIT;
                                pRecAdiutoSetupDetail."Line No." := lIntFamilyId;
                                pRecAdiutoSetupDetail."Id Family Document" := lIntFamilyId;
                                pRecAdiutoSetupDetail."Name Family Document" := lTxtFamilyDescription;
                                pRecAdiutoSetupDetail.Description := lTxtFamilyDescription;
                                pRecAdiutoSetupDetail."Document Type" := 0;
                                pRecAdiutoSetupDetail.INSERT(FALSE);
                            END;
                        END ELSE BEGIN
                            IF (pIntFamilyId = lIntFamilyId) THEN BEGIN
                                XmlNodeListChild := XmlNode.ChildNodes;
                                IF XmlNodeListChild.Count > 0 THEN BEGIN
                                    FOR lIntIndexChild := 0 TO (XmlNodeListChild.Count - 1) DO BEGIN
                                        XmlNodeChild := XmlNodeListChild.Item(lIntIndexChild);
                                        IF ISNULL(XmlNodeChild) = FALSE THEN BEGIN
                                            XmlNodeListChildFields := XmlNodeChild.ChildNodes;
                                            FOR lIntIndexChildFields := 0 TO (XmlNodeListChildFields.Count - 1) DO BEGIN
                                                XmlNodeChildField := XmlNodeListChildFields.Item(lIntIndexChildFields);
                                                IF ISNULL(XmlNodeChildField) = FALSE THEN BEGIN
                                                    IF XmlNodeChildField.Name = 'id' THEN
                                                        EVALUATE(lIntId, XmlNodeChildField.InnerText);
                                                    IF XmlNodeChildField.Name = 'label' THEN BEGIN
                                                        lTxtNameGetField := XmlNodeChildField.InnerText;
                                                    END;
                                                END;
                                            END;
                                            //Sotto il 1000 sono campi di sistema
                                            IF lIntId >= 1000 THEN BEGIN
                                                pRecAdiutoSetupDetail.INIT;
                                                pRecAdiutoSetupDetail."Line No." := lIntId;
                                                pRecAdiutoSetupDetail."Id Family Document" := lIntId;
                                                pRecAdiutoSetupDetail."Name Family Document" := lTxtNameGetField;
                                                pRecAdiutoSetupDetail.Description := '';
                                                pRecAdiutoSetupDetail."Document Type" := 0;
                                                pRecAdiutoSetupDetail.Description := lTxtNameGetField;
                                                pRecAdiutoSetupDetail.INSERT(FALSE);
                                            END;
                                        END;
                                    END;
                                END;
                            END;
                        END;
                    END;
                END;
            END;
        END;
    end;

    procedure InsertDocument(pTxtFileName: Text; pTxtFileContent: Text; pRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED"; pRefRecord: RecordRef) Result: Integer
    var
        Convert: DotNet Convert;
        ClientFile: DotNet File;
        lIntNumFields: Integer;
        lIntIndex: Integer;
        lCduFileManagement: Codeunit "File Management";
        HttpClient: DotNet HttpClient;
        HttpContent: DotNet HttpContent;
        Parameters: DotNet SortedDictionary_Of_T_U;
        HttpResponseMessage: DotNet HttpResponseMessage;
        lTxtContent: BigText;
        lTxtEnvelopeXML: Text;
        lTxtFields: BigText;
        lTxtValues: BigText;
        lTxtOperators: BigText;
        lTxtResult: Text;
    begin
        LoginAdijedWS;

        IF NOT gRecAdiutoSetup.GET THEN
            ERROR(Text002);

        Parameters := Parameters.SortedDictionary();
        Parameters.Add('baseurl', 'http://' + gRecAdiutoSetup."Ip Address" + ':' + FORMAT(gRecAdiutoSetup.Port));
        Parameters.Add('path', '/adiJed/services/AdiJedWS');
        Parameters.Add('restmethod', 'POST');
        Parameters.Add('ContentType', 'text/xml; charset=utf-8');
        Parameters.Add('SOAPAction', 'insertDocument');

        lTxtContent.ADDTEXT('<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
                            '<soap:Body><ns1:insertDocument xmlns:ns1="http://ws.adiJed">' +
                            '<ns1:session-id>' + gIdSessionAdijedWS + '</ns1:session-id>');

        lTxtContent.ADDTEXT('<ns1:file>' + pTxtFileContent + '</ns1:file>' +
                            '<ns1:filename>' + pTxtFileName + '</ns1:filename>');

        lTxtContent.ADDTEXT('<ns1:family-id>' + FORMAT(pRecAdiutoSetupDetail."Id Family Document") + '</ns1:family-id>');

        GetInsertFieldsIdValuesParameters(pRecAdiutoSetupDetail, pRefRecord, lTxtFields, lTxtValues);

        lTxtContent.ADDTEXT(lTxtFields);
        lTxtContent.ADDTEXT(lTxtValues);

        lTxtContent.ADDTEXT('</ns1:insertDocument></soap:Body></soap:Envelope>');

        Parameters.Add('httpcontent', lTxtContent);

        CallRESTWebService(Parameters, HttpResponseMessage);
        lTxtEnvelopeXML := HttpResponseMessage.Content.ReadAsStringAsync.Result;
        IF HttpResponseMessage.StatusCode <> 200 THEN BEGIN
            LogoutAdijedWS;
            ERROR('Http Error ' + ' ' + FORMAT(HttpResponseMessage.StatusCode) + ': ' + lTxtEnvelopeXML);
        END;

        GetXmlTagValue(lTxtEnvelopeXML, 'ns1:newDocumentIndexes', lTxtResult);
        EVALUATE(Result, lTxtResult);

        IF Result < 0 THEN BEGIN
            LogoutAdijedWS;
            ERROR(Text004);
        END;

        LogoutAdijedWS;
    end;

    procedure ModifyDocument(pIntDocumentId: Integer; pRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED"; pRefRecord: RecordRef) Result: Integer
    var
        Convert: DotNet Convert;
        ClientFile: DotNet File;
        lIntNumFields: Integer;
        lIntIndex: Integer;
        lCduFileManagement: Codeunit "File Management";
        HttpClient: DotNet HttpClient;
        HttpContent: DotNet HttpContent;
        Parameters: DotNet SortedDictionary_Of_T_U;
        HttpResponseMessage: DotNet HttpResponseMessage;
        lTxtContent: BigText;
        lTxtEnvelopeXML: Text;
        lTxtFields: BigText;
        lTxtValues: BigText;
    begin
        LoginAdijedWS;

        IF NOT gRecAdiutoSetup.GET THEN
            ERROR(Text002);

        Parameters := Parameters.SortedDictionary();
        Parameters.Add('baseurl', 'http://' + gRecAdiutoSetup."Ip Address" + ':' + FORMAT(gRecAdiutoSetup.Port));
        Parameters.Add('path', '/adiJed/services/AdiJedWS');
        Parameters.Add('restmethod', 'POST');
        Parameters.Add('ContentType', 'text/xml; charset=utf-8');
        Parameters.Add('SOAPAction', 'modifyDocument');

        lTxtContent.ADDTEXT('<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
                        '<soap:Body><ns1:modifyDocument xmlns:ns1="http://ws.adiJed">' +
                        '<ns1:session-id>' + gIdSessionAdijedWS + '</ns1:session-id>' +
                        '<ns1:document-id>' + FORMAT(pIntDocumentId) + '</ns1:document-id>');

        IF GetUpdateFieldsIdValuesParameters(pRecAdiutoSetupDetail, pRefRecord, lTxtFields, lTxtValues) THEN BEGIN

            lTxtContent.ADDTEXT(lTxtFields);
            lTxtContent.ADDTEXT(lTxtValues);

            lTxtContent.ADDTEXT('</ns1:modifyDocument></soap:Body></soap:Envelope>');

            Parameters.Add('httpcontent', lTxtContent);

            CallRESTWebService(Parameters, HttpResponseMessage);
            lTxtEnvelopeXML := HttpResponseMessage.Content.ReadAsStringAsync.Result;
            IF HttpResponseMessage.StatusCode <> 200 THEN BEGIN
                LogoutAdijedWS;
                ERROR('Http Error ' + ' ' + FORMAT(HttpResponseMessage.StatusCode) + ': ' + lTxtEnvelopeXML);
            END;

            IF lTxtEnvelopeXML = '-1' THEN BEGIN
                LogoutAdijedWS;
                ERROR(Text003);
            END;
        END;
        LogoutAdijedWS;
    end;

    procedure DeleteDocument(pIntIdDocAdiuto: Integer) Result: Integer
    var
        Convert: DotNet Convert;
        ClientFile: DotNet File;
        lTxtXmlToSend: BigText;
        lIntNumFields: Integer;
        lIntIndex: Integer;
        lCduFileManagement: Codeunit "File Management";
        HttpClient: DotNet HttpClient;
        HttpContent: DotNet HttpContent;
        Parameters: DotNet SortedDictionary_Of_T_U;
        HttpResponseMessage: DotNet HttpResponseMessage;
        lBigTxtContent: BigText;
        lTxtEnvelopeXML: Text;
    begin
        LoginAdijedWS;

        IF NOT gRecAdiutoSetup.GET THEN
            ERROR(Text002);

        Parameters := Parameters.SortedDictionary();
        Parameters.Add('baseurl', 'http://' + gRecAdiutoSetup."Ip Address" + ':' + FORMAT(gRecAdiutoSetup.Port));
        Parameters.Add('path', '/adiJed/services/AdiJedWS');
        Parameters.Add('restmethod', 'POST');
        Parameters.Add('ContentType', 'text/xml; charset=utf-8');
        Parameters.Add('SOAPAction', 'deleteDocument');

        lBigTxtContent.ADDTEXT('<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
                              '<soap:Body><ns1:deleteDocument xmlns:ns1="http://ws.adiJed">' +
                              '<ns1:session-id>' + gIdSessionAdijedWS + '</ns1:session-id>' +
                              '<ns1:document-id>' + FORMAT(pIntIdDocAdiuto) + '</ns1:document-id>');

        lBigTxtContent.ADDTEXT('</ns1:deleteDocument></soap:Body></soap:Envelope>');

        Parameters.Add('httpcontent', lBigTxtContent);

        CallRESTWebService(Parameters, HttpResponseMessage);
        lTxtEnvelopeXML := HttpResponseMessage.Content.ReadAsStringAsync.Result;
        IF HttpResponseMessage.StatusCode <> 200 THEN BEGIN
            LogoutAdijedWS;
            ERROR('Http Error ' + ' ' + FORMAT(HttpResponseMessage.StatusCode) + ': ' + lTxtEnvelopeXML);
        END;

        IF lTxtEnvelopeXML = '-1' THEN BEGIN
            LogoutAdijedWS;
            ERROR(Text005);
        END;

        LogoutAdijedWS;

        EVALUATE(Result, lTxtEnvelopeXML);
    end;

    procedure GetDocId(pRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED"; var pRefRecord: RecordRef) Result: Text
    var
        lIntIndex: Integer;
        Parameters: DotNet SortedDictionary_Of_T_U;
        lTxtContent: BigText;
        HttpResponseMessage: DotNet HttpResponseMessage;
        lRecAdiutoSetupDetailLines: Record "Adiuto Setup Detail Lines ED";
        lTxtFields: BigText;
        lTxtValues: BigText;
        lTxtOperators: BigText;
        lTxtXML: Text;
        lTxtEnvelopeXML: Text;
        XmlNodeList: DotNet XmlNodeList;
        XmlDocument: DotNet XmlDocument;
        XmlDoc: Codeunit "XML DOM Management";
        XmlNode: DotNet XmlNode;
        XmlAttributes: DotNet XmlAttributeCollection;
    begin
        lTxtXML := '';
        lTxtEnvelopeXML := ExecuteQuery(pRecAdiutoSetupDetail, pRefRecord);
        IF lTxtEnvelopeXML = '' THEN
            EXIT(lTxtXML);

        XmlDoc.LoadXMLDocumentFromText(lTxtEnvelopeXML, XmlDocument);
        //UPDATE        XmlDocument.FirstChild;
        XmlDocument := XmlDocument.FirstChild;
        XmlNodeList := XmlDocument.GetElementsByTagName('dato');

        IF XmlNodeList.Count > 0 THEN BEGIN
            FOR lIntIndex := 0 TO XmlNodeList.Count DO BEGIN
                XmlNode := XmlNodeList.Item(lIntIndex);
                IF ISNULL(XmlNode) = FALSE THEN BEGIN
                    XmlAttributes := XmlNode.Attributes;
                    IF UPPERCASE(XmlAttributes.GetNamedItem('nome').Value) = UPPERCASE('idUnivoco') THEN
                        lTxtXML := XmlNode.InnerText;
                END;
            END;
        END;

        EXIT(lTxtXML);
    end;

    procedure ExecuteQuery(pRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED"; var pRefRecord: RecordRef): Text
    var
        Parameters: DotNet SortedDictionary_Of_T_U;
        lTxtContent: BigText;
        HttpResponseMessage: DotNet HttpResponseMessage;
        lTxtEnvelopeXML: Text;
        lTxtXML: Text;
        lTxtTag: Text;
        XmlNode: DotNet XmlNode;
        XmlNodeList: DotNet XmlNodeList;
        XmlNodeChild: DotNet XmlNode;
        lIntIndex: Integer;
        XmlDocument: DotNet XmlDocument;
        XmlNSM: DotNet XmlNamespaceManager;
        XmlNameTable: DotNet XmlNameTable;
        out: OutStream;
        MyFile: File;
        blnLoop: Boolean;
        XmlDocumentChild: DotNet XmlDocument;
        XmlDocChild: Codeunit "XML DOM Management";
        XmlDoc: Codeunit "XML DOM Management";
        lTxtFields: BigText;
        lTxtValues: BigText;
        lTxtOperators: BigText;
        lBlnLoop: Boolean;
        XmlAttributes: DotNet XmlAttributeCollection;
    begin
        IF gIdSessionAdijedWS = '' THEN
            LoginAdijedWS;

        Parameters := Parameters.SortedDictionary();
        Parameters.Add('baseurl', 'http://' + gRecAdiutoSetup."Ip Address" + ':' + FORMAT(gRecAdiutoSetup.Port));
        Parameters.Add('path', '/adiJed/services/SDKService');
        Parameters.Add('restmethod', 'POST');
        Parameters.Add('ContentType', 'text/xml; charset=utf-8');
        Parameters.Add('SOAPAction', 'executeQueryWithRightandID');

        lTxtContent.ADDTEXT('<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
                       '<soap:Body><ns1:executeQueryWithRightandID xmlns:ns1="http://ws.adiJed">' +
                       '<ns1:session-id>' + gIdSessionAdijedWS + '</ns1:session-id>' +
                       '<ns1:family-id>' + FORMAT(pRecAdiutoSetupDetail."Id Family Document") + '</ns1:family-id>');

        GetSearchFieldsIdValuesParameters(pRecAdiutoSetupDetail, pRefRecord, lTxtFields, lTxtValues, lTxtOperators);

        lTxtContent.ADDTEXT(lTxtFields);
        lTxtContent.ADDTEXT(lTxtValues);
        lTxtContent.ADDTEXT('<ns1:values2><ns1:string></ns1:string></ns1:values2>');
        lTxtContent.ADDTEXT(lTxtOperators);
        lTxtContent.ADDTEXT('<ns1:auth></ns1:auth>');
        lTxtContent.ADDTEXT('<ns1:links>false</ns1:links>');
        lTxtContent.ADDTEXT('<ns1:attachments>false</ns1:attachments>');
        lTxtContent.ADDTEXT('</ns1:executeQueryWithRightandID></soap:Body></soap:Envelope>');

        Parameters.Add('httpcontent', lTxtContent);

        CallRESTWebService(Parameters, HttpResponseMessage);
        lTxtEnvelopeXML := HttpResponseMessage.Content.ReadAsStringAsync.Result;
        IF HttpResponseMessage.StatusCode <> 200 THEN BEGIN
            LogoutAdijedWS;
            ERROR('Http Error ' + ' ' + FORMAT(HttpResponseMessage.StatusCode) + ': ' + lTxtEnvelopeXML);
        END;

        LogoutAdijedWS;

        XmlDoc.LoadXMLDocumentFromText(lTxtEnvelopeXML, XmlDocument);

        lTxtXML := '';
        lBlnLoop := TRUE;
        REPEAT
            lTxtXML := XmlDocument.Value;
            XmlDocument := XmlDocument.FirstChild;
            IF ISNULL(XmlDocument) = TRUE THEN
                lBlnLoop := FALSE;
        UNTIL lBlnLoop = FALSE;

        EXIT(lTxtXML);
    end;

    procedure ExecuteQueryRest(pRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED"; pRefRecord: RecordRef; var pTxtPath: BigText)
    var
        Parameters: DotNet SortedDictionary_Of_T_U;
        HttpResponseMessage: DotNet HttpResponseMessage;
        lTxtResponse: Text;
        lTxtQuery: BigText;
        HttpUtility: DotNet HttpUtility;
    begin
        IF NOT gRecAdiutoSetup.GET THEN
            ERROR(Text002);
        //IF gIdSessionAdijedWS = '' THEN
        //  LoginAdijedWS;
        pTxtPath.ADDTEXT('http://' + gRecAdiutoSetup."Ip Address" + ':' + FORMAT(gRecAdiutoSetup.Port));
        //Parameters.Add('ContentType', 'text/xml; charset=utf-8');
        //Parameters.Add('SOAPAction','executeQueryWithRightandID');
        pTxtPath.ADDTEXT('/adiJed/rest/query/executeQuery');
        pTxtPath.ADDTEXT('?');
        pTxtPath.ADDTEXT('username=');
        pTxtPath.ADDTEXT(gRecAdiutoSetup.User);
        pTxtPath.ADDTEXT('&');
        pTxtPath.ADDTEXT('password=');
        pTxtPath.ADDTEXT(gRecAdiutoSetup.Password);
        pTxtPath.ADDTEXT('&');
        pTxtPath.ADDTEXT('companyId=');
        pTxtPath.ADDTEXT(FORMAT(gRecAdiutoSetup."Company Id"));
        pTxtPath.ADDTEXT('&');

        pTxtPath.ADDTEXT('query=');
        GetSearchFieldsIdValuesParametersRest(pRecAdiutoSetupDetail, pRefRecord, lTxtQuery);
        pTxtPath.ADDTEXT(HttpUtility.UrlEncodeUnicode(lTxtQuery));

        /*
        Parameters := Parameters.SortedDictionary();
        Parameters.Add('baseurl','http://' + gRecAdiutoSetup."Ip Address"  + ':' + FORMAT(gRecAdiutoSetup.Port));
        Parameters.Add('path',lTxtPath);
        MESSAGE(FORMAT(lTxtPath));
        Parameters.Add('restmethod','GET');

        CallRESTWebService(Parameters,HttpResponseMessage);
        lTxtResponse := HttpResponseMessage.Content.ReadAsStringAsync.Result;
        IF HttpResponseMessage.StatusCode <> 200 THEN BEGIN
          LogoutAdijedWS;
          ERROR('Http Error ' + ' ' + FORMAT(HttpResponseMessage.StatusCode) + ': ' + lTxtResponse);
        END;

        EXIT(lTxtResponse);
        */

    end;

    procedure ExecuteQueryRestByBarcode(pRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED"; pTxtBarcode: Text; var pTxtPath: BigText)
    var
        Parameters: DotNet SortedDictionary_Of_T_U;
        HttpResponseMessage: DotNet HttpResponseMessage;
        lTxtResponse: Text;
        lTxtQuery: BigText;
        HttpUtility: DotNet HttpUtility;
    begin
        IF NOT gRecAdiutoSetup.GET THEN
            ERROR(Text002);

        pTxtPath.ADDTEXT('http://' + gRecAdiutoSetup."Ip Address" + ':' + FORMAT(gRecAdiutoSetup.Port));
        pTxtPath.ADDTEXT('/adiJed/rest/query/executeQuery');
        pTxtPath.ADDTEXT('?');
        pTxtPath.ADDTEXT('username=');
        pTxtPath.ADDTEXT(gRecAdiutoSetup.User);
        pTxtPath.ADDTEXT('&');
        pTxtPath.ADDTEXT('password=');
        pTxtPath.ADDTEXT(gRecAdiutoSetup.Password);
        pTxtPath.ADDTEXT('&');
        pTxtPath.ADDTEXT('companyId=');
        pTxtPath.ADDTEXT(FORMAT(gRecAdiutoSetup."Company Id"));
        pTxtPath.ADDTEXT('&');

        pTxtPath.ADDTEXT('query=');
        lTxtQuery.ADDTEXT('{');
        lTxtQuery.ADDTEXT('"query":[');
        lTxtQuery.ADDTEXT('{');
        lTxtQuery.ADDTEXT('"fam":');
        lTxtQuery.ADDTEXT(FORMAT(pRecAdiutoSetupDetail."Id Family Document"));
        lTxtQuery.ADDTEXT(',');
        lTxtQuery.ADDTEXT('"f":');
        lTxtQuery.ADDTEXT('[');
        lTxtQuery.ADDTEXT(FORMAT(pRecAdiutoSetupDetail."El. Doc. Barcode Fld. Id"));
        lTxtQuery.ADDTEXT(']');
        lTxtQuery.ADDTEXT(',');
        lTxtQuery.ADDTEXT('"o":');
        lTxtQuery.ADDTEXT('["="]');
        lTxtQuery.ADDTEXT(',');
        lTxtQuery.ADDTEXT('"v1":');
        lTxtQuery.ADDTEXT('["' + pTxtBarcode + '"]');
        lTxtQuery.ADDTEXT('"v2":[],');
        lTxtQuery.ADDTEXT('"order":"",');
        lTxtQuery.ADDTEXT('"asc":false,');
        lTxtQuery.ADDTEXT('"max":0');
        lTxtQuery.ADDTEXT('}');
        lTxtQuery.ADDTEXT(']');
        lTxtQuery.ADDTEXT('}');
        pTxtPath.ADDTEXT(HttpUtility.UrlEncodeUnicode(lTxtQuery));
    end;

    local procedure GetSearchFieldsValuesParameters(pRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED"; pRefRecord: RecordRef; var pTxtFields: BigText; var pTxtValues: BigText; var pTxtOperators: BigText)
    var
        lRecAdiutoSetupDetailLines: Record "Adiuto Setup Detail Lines ED";
    begin
        pTxtFields.ADDTEXT('<ns1:fields>');
        pTxtValues.ADDTEXT('<ns1:values>');
        pTxtOperators.ADDTEXT('<ns1:operators>');

        lRecAdiutoSetupDetailLines.RESET;
        lRecAdiutoSetupDetailLines.SETRANGE("Primary Key", pRecAdiutoSetupDetail."Primary Key");
        lRecAdiutoSetupDetailLines.SETRANGE("Line No.", pRecAdiutoSetupDetail."Line No.");
        lRecAdiutoSetupDetailLines.SETRANGE("Use for Searching", TRUE);
        IF lRecAdiutoSetupDetailLines.FINDSET THEN BEGIN
            REPEAT
                pTxtFields.ADDTEXT('<ns1:string>' + FORMAT(lRecAdiutoSetupDetailLines."Adiuto Field Name") + '</ns1:string>');
                pTxtValues.ADDTEXT('<ns1:string>' + GetFieldValue(pRefRecord, lRecAdiutoSetupDetailLines) + '</ns1:string>');
                pTxtOperators.ADDTEXT('<ns1:string>=</ns1:string>');
            UNTIL lRecAdiutoSetupDetailLines.NEXT = 0;
        END;
        pTxtFields.ADDTEXT('</ns1:fields>');
        pTxtValues.ADDTEXT('</ns1:values>');
        pTxtOperators.ADDTEXT('</ns1:operators>');
    end;

    local procedure GetSearchFieldsIdValuesParameters(pRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED"; pRefRecord: RecordRef; var pTxtFields: BigText; var pTxtValues: BigText; var pTxtOperators: BigText)
    var
        lRecAdiutoSetupDetailLines: Record "Adiuto Setup Detail Lines ED";
    begin
        pTxtFields.ADDTEXT('<ns1:fields-id>');
        pTxtValues.ADDTEXT('<ns1:values1>');
        pTxtOperators.ADDTEXT('<ns1:operators>');

        lRecAdiutoSetupDetailLines.RESET;
        lRecAdiutoSetupDetailLines.SETRANGE("Primary Key", pRecAdiutoSetupDetail."Primary Key");
        lRecAdiutoSetupDetailLines.SETRANGE("Line No.", pRecAdiutoSetupDetail."Line No.");
        lRecAdiutoSetupDetailLines.SETRANGE("Use for Searching", TRUE);
        IF lRecAdiutoSetupDetailLines.FINDSET THEN BEGIN
            REPEAT
                pTxtFields.ADDTEXT('<ns1:int>' + FORMAT(lRecAdiutoSetupDetailLines."Adiuto Field Id") + '</ns1:int>');
                pTxtValues.ADDTEXT('<ns1:string>' + GetFieldValue(pRefRecord, lRecAdiutoSetupDetailLines) + '</ns1:string>');
                pTxtOperators.ADDTEXT('<ns1:string>=</ns1:string>');
            UNTIL lRecAdiutoSetupDetailLines.NEXT = 0;
        END;
        pTxtFields.ADDTEXT('</ns1:fields-id>');
        pTxtValues.ADDTEXT('</ns1:values1>');
        pTxtOperators.ADDTEXT('</ns1:operators>');
    end;

    local procedure GetUpdateFieldsIdValuesParameters(pRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED"; pRefRecord: RecordRef; var pTxtFields: BigText; var pTxtValues: BigText) rBlnFound: Boolean
    var
        lRecAdiutoSetupDetailLines: Record "Adiuto Setup Detail Lines ED";
    begin
        rBlnFound := FALSE;
        pTxtFields.ADDTEXT('<ns1:fields-id>');
        pTxtValues.ADDTEXT('<ns1:values>');
        lRecAdiutoSetupDetailLines.RESET;
        lRecAdiutoSetupDetailLines.SETRANGE("Primary Key", pRecAdiutoSetupDetail."Primary Key");
        lRecAdiutoSetupDetailLines.SETRANGE("Line No.", pRecAdiutoSetupDetail."Line No.");
        lRecAdiutoSetupDetailLines.SETRANGE("Use for Update", TRUE);
        IF lRecAdiutoSetupDetailLines.FINDSET THEN BEGIN
            REPEAT
                rBlnFound := TRUE;
                pTxtFields.ADDTEXT('<ns1:int>' + FORMAT(lRecAdiutoSetupDetailLines."Adiuto Field Id") + '</ns1:int>');
                pTxtValues.ADDTEXT('<ns1:string>' + GetFieldValue(pRefRecord, lRecAdiutoSetupDetailLines) + '</ns1:string>');
            UNTIL lRecAdiutoSetupDetailLines.NEXT = 0;
        END;
        pTxtFields.ADDTEXT('</ns1:fields-id>');
        pTxtValues.ADDTEXT('</ns1:values>');
    end;

    local procedure GetSearchFieldsIdValuesParametersRest(pRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED"; pRefRecord: RecordRef; var pTxtQuery: BigText)
    var
        lRecAdiutoSetupDetailLines: Record "Adiuto Setup Detail Lines ED";
        lTxtFields: BigText;
        lTxtValues: BigText;
        lTxtOperators: BigText;
    begin
        lTxtFields.ADDTEXT('[');
        lTxtValues.ADDTEXT('[');
        lTxtOperators.ADDTEXT('[');

        lRecAdiutoSetupDetailLines.RESET;
        lRecAdiutoSetupDetailLines.SETRANGE("Primary Key", pRecAdiutoSetupDetail."Primary Key");
        lRecAdiutoSetupDetailLines.SETRANGE("Line No.", pRecAdiutoSetupDetail."Line No.");
        lRecAdiutoSetupDetailLines.SETRANGE("Use for Searching", TRUE);
        IF lRecAdiutoSetupDetailLines.FINDSET THEN BEGIN
            REPEAT
                IF lTxtFields.LENGTH > 1 THEN
                    lTxtFields.ADDTEXT(',');
                lTxtFields.ADDTEXT(FORMAT(lRecAdiutoSetupDetailLines."Adiuto Field Id"));

                IF lTxtValues.LENGTH > 1 THEN
                    lTxtValues.ADDTEXT(',');
                lTxtValues.ADDTEXT('"');
                lTxtValues.ADDTEXT(GetFieldValue(pRefRecord, lRecAdiutoSetupDetailLines));
                lTxtValues.ADDTEXT('"');

                IF lTxtOperators.LENGTH > 1 THEN
                    lTxtOperators.ADDTEXT(',');
                lTxtOperators.ADDTEXT('"="');

            UNTIL lRecAdiutoSetupDetailLines.NEXT = 0;
        END;

        pTxtQuery.ADDTEXT('{');
        pTxtQuery.ADDTEXT('"query":[');
        pTxtQuery.ADDTEXT('{');
        pTxtQuery.ADDTEXT('"fam":');
        pTxtQuery.ADDTEXT(FORMAT(pRecAdiutoSetupDetail."Id Family Document"));
        pTxtQuery.ADDTEXT(',');
        pTxtQuery.ADDTEXT('"f":');
        pTxtQuery.ADDTEXT(lTxtFields);
        pTxtQuery.ADDTEXT('],');
        pTxtQuery.ADDTEXT('"o":');
        pTxtQuery.ADDTEXT(lTxtOperators);
        pTxtQuery.ADDTEXT('],');
        pTxtQuery.ADDTEXT('"v1":');
        pTxtQuery.ADDTEXT(lTxtValues);
        pTxtQuery.ADDTEXT('],');
        pTxtQuery.ADDTEXT('"v2":[],');
        pTxtQuery.ADDTEXT('"order":"",');
        pTxtQuery.ADDTEXT('"asc":false,');
        pTxtQuery.ADDTEXT('"max":0');
        pTxtQuery.ADDTEXT('}');
        pTxtQuery.ADDTEXT(']');
        pTxtQuery.ADDTEXT('}');
    end;

    [TryFunction]
    local procedure GetXmlTagValue(pTxtXml: Text; pTxtTag: Text; var pTxtResult: Text)
    var
        lTxtFamilyDescription: Text;
        lIntFamilyId: Integer;
        lTxtXML: Text;
        XmlNodeList: DotNet XmlNodeList;
        XmlAttributes: DotNet XmlAttributeCollection;
        XmlDocument: DotNet XmlDocument;
        XmlNSM: DotNet XmlNamespaceManager;
        XmlNameTable: DotNet XmlNameTable;
        out: OutStream;
        MyFile: File;
        blnLoop: Boolean;
        XmlDocumentChild: DotNet XmlDocument;
        XmlDocChild: Codeunit "XML DOM Management";
        XmlDoc: Codeunit "XML DOM Management";
        lPagAdiutoFamilyList: Page "Adiuto Family List ED";
        XmlNodeListChild: DotNet XmlNodeList;
        XmlNodeChild: DotNet XmlNode;
        XmlNode: DotNet XmlNode;
        lIntIndexChild: Integer;
        lIntIndex: Integer;
        XmlNodeListChildFields: DotNet XmlNodeList;
        lIntIndexChildFields: Integer;
        XmlNodeChildField: DotNet XmlNode;
        lIntId: Integer;
        lTxtNameGetField: Text;
        lBlnLoop: Boolean;
    begin
        pTxtResult := '';
        IF pTxtXml <> '' THEN BEGIN
            XmlDoc.LoadXMLDocumentFromText(pTxtXml, XmlDocument);
            XmlNode := XmlDocument.FirstChild;
            lBlnLoop := TRUE;
            REPEAT
                IF NOT ISNULL(XmlNode) THEN BEGIN
                    IF XmlNode.Name = pTxtTag THEN BEGIN
                        pTxtResult := XmlNode.InnerText;
                        lBlnLoop := FALSE;
                    END;
                    XmlNode := XmlNode.FirstChild;
                END
                ELSE BEGIN
                    lBlnLoop := FALSE;
                END;
            UNTIL lBlnLoop = FALSE;
        END;
    end;

    local procedure GetNavFieldType(pIntTableId: Integer; pIntFieldId: Integer) rTxtType: Text
    var
        lRecField: Record "Field";
    begin
        rTxtType := '';
        IF lRecField.GET(pIntTableId, pIntFieldId) THEN BEGIN
            rTxtType := FORMAT(lRecField.Type);
        END;
    end;

    local procedure GetNavFieldClass(pIntTableId: Integer; pIntFieldId: Integer) rTxtType: Text
    var
        lRecField: Record "Field";
    begin
        rTxtType := '';
        IF lRecField.GET(pIntTableId, pIntFieldId) THEN BEGIN
            rTxtType := FORMAT(lRecField.Class);
        END;
    end;

    procedure GetFieldValue(pRefRecord: RecordRef; lRecAdiutoSetupDetailLines: Record "Adiuto Setup Detail Lines ED") rTxtValue: Text
    var
        lRecField: Record "Field";
        lFldRef: FieldRef;
        lTxtType: Text;
        lTxtClass: Text;
    begin
        rTxtValue := '';
        lTxtClass := GetNavFieldClass(pRefRecord.NUMBER, lRecAdiutoSetupDetailLines."NAV Field Id");
        lTxtType := GetNavFieldType(pRefRecord.NUMBER, lRecAdiutoSetupDetailLines."NAV Field Id");
        lFldRef := pRefRecord.FIELD(lRecAdiutoSetupDetailLines."NAV Field Id");
        IF lTxtClass = 'FlowField' THEN
            lFldRef.CALCFIELD;
        rTxtValue := FORMAT(lFldRef.VALUE);
        IF lTxtType = 'Date' THEN
            rTxtValue := FORMAT(lFldRef.VALUE, 0, '<Year4><Month,2><Day,2>');
        //>ADI-001
        IF lTxtType = 'Decimal' THEN BEGIN
            IF lRecAdiutoSetupDetailLines."Decimal Separator" <> '' THEN
                rTxtValue := FORMAT(lFldRef.VALUE, 0, '<Sign><Integer><Decimals><Comma,' + lRecAdiutoSetupDetailLines."Decimal Separator" + '>');
        END;
        //<ADI-001
        rTxtValue := DELCHR(rTxtValue, '=', '&');
    end;

    procedure ElectrInvoiceGetStatus(pRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED"; pRefRecord: RecordRef): Text
    var
        Parameters: DotNet SortedDictionary_Of_T_U;
        lTxtContent: BigText;
        HttpResponseMessage: DotNet HttpResponseMessage;
        lTxtEnvelopeXML: Text;
        lTxtXML: Text;
        lTxtTag: Text;
        XmlNode: DotNet XmlNode;
        XmlNodeList: DotNet XmlNodeList;
        XmlNodeChild: DotNet XmlNode;
        lIntIndex: Integer;
        XmlDocument: DotNet XmlDocument;
        XmlNSM: DotNet XmlNamespaceManager;
        XmlNameTable: DotNet XmlNameTable;
        out: OutStream;
        MyFile: File;
        blnLoop: Boolean;
        XmlDocumentChild: DotNet XmlDocument;
        XmlDocChild: Codeunit "XML DOM Management";
        XmlDoc: Codeunit "XML DOM Management";
        lTxtFields: BigText;
        lTxtValues: BigText;
        lTxtOperators: BigText;
        lBlnLoop: Boolean;
        XmlAttributes: DotNet XmlAttributeCollection;
    begin
        lTxtXML := '';
        lTxtEnvelopeXML := ExecuteQuery(pRecAdiutoSetupDetail, pRefRecord);
        IF lTxtEnvelopeXML = '' THEN
            EXIT(lTxtXML);

        XmlDoc.LoadXMLDocumentFromText(lTxtEnvelopeXML, XmlDocument);
        //UPDATE        XmlDocument.FirstChild;
        XmlDocument := XmlDocument.FirstChild;
        XmlNodeList := XmlDocument.GetElementsByTagName('dato');

        IF XmlNodeList.Count > 0 THEN BEGIN
            FOR lIntIndex := 0 TO XmlNodeList.Count DO BEGIN
                XmlNode := XmlNodeList.Item(lIntIndex);
                IF ISNULL(XmlNode) = FALSE THEN BEGIN
                    XmlAttributes := XmlNode.Attributes;
                    IF UPPERCASE(XmlAttributes.GetNamedItem('nome').Value) = UPPERCASE(pRecAdiutoSetupDetail."El. Doc. Status Fld. Name") THEN
                        lTxtXML := XmlNode.InnerText;
                END;
            END;
        END;

        EXIT(lTxtXML);
    end;

    procedure ElectrInvoiceModifyDoc(pIntDocumentId: Integer; pRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED"; pRecAdiutoElectrInv: Record "Adiuto Electr. Doc.") Result: Integer
    var
        Convert: DotNet Convert;
        ClientFile: DotNet File;
        lIntNumFields: Integer;
        lIntIndex: Integer;
        lCduFileManagement: Codeunit "File Management";
        HttpClient: DotNet HttpClient;
        HttpContent: DotNet HttpContent;
        Parameters: DotNet SortedDictionary_Of_T_U;
        HttpResponseMessage: DotNet HttpResponseMessage;
        lTxtContent: BigText;
        lTxtEnvelopeXML: Text;
        lTxtFields: BigText;
        lTxtValues: BigText;
        lRecAdiutoElectrInv: Record "Adiuto Electr. Doc.";
        lCduAdiutoDocuments: Codeunit "Adiuto Documents ED";
    begin
        LoginAdijedWS;

        IF NOT gRecAdiutoSetup.GET THEN
            ERROR(Text002);

        Parameters := Parameters.SortedDictionary();
        Parameters.Add('baseurl', 'http://' + gRecAdiutoSetup."Ip Address" + ':' + FORMAT(gRecAdiutoSetup.Port));
        Parameters.Add('path', '/adiJed/services/AdiJedWS');
        Parameters.Add('restmethod', 'POST');
        Parameters.Add('ContentType', 'text/xml; charset=utf-8');
        Parameters.Add('SOAPAction', 'modifyDocument');

        lTxtContent.ADDTEXT('<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
                        '<soap:Body><ns1:modifyDocument xmlns:ns1="http://ws.adiJed">' +
                        '<ns1:session-id>' + gIdSessionAdijedWS + '</ns1:session-id>' +
                        '<ns1:document-id>' + FORMAT(pIntDocumentId) + '</ns1:document-id>');

        lTxtFields.ADDTEXT('<ns1:fields-id>');
        lTxtValues.ADDTEXT('<ns1:values>');

        lTxtFields.ADDTEXT('<ns1:int>' + FORMAT(pRecAdiutoSetupDetail."El. Doc. Status Fld. Id") + '</ns1:int>');
        lTxtValues.ADDTEXT('<ns1:string>' + pRecAdiutoElectrInv.Status + '</ns1:string>');

        lTxtFields.ADDTEXT('</ns1:fields-id>');
        lTxtValues.ADDTEXT('</ns1:values>');

        lTxtContent.ADDTEXT(lTxtFields);
        lTxtContent.ADDTEXT(lTxtValues);

        lTxtContent.ADDTEXT('</ns1:modifyDocument></soap:Body></soap:Envelope>');

        Parameters.Add('httpcontent', lTxtContent);

        CallRESTWebService(Parameters, HttpResponseMessage);
        lTxtEnvelopeXML := HttpResponseMessage.Content.ReadAsStringAsync.Result;
        IF HttpResponseMessage.StatusCode <> 200 THEN BEGIN
            LogoutAdijedWS;
            ERROR('Http Error ' + ' ' + FORMAT(HttpResponseMessage.StatusCode) + ': ' + lTxtEnvelopeXML);
        END;

        LogoutAdijedWS;
    end;

    local procedure ElectrInvoiceExecuteQuery(pRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED"): Text
    var
        Parameters: DotNet SortedDictionary_Of_T_U;
        lTxtContent: BigText;
        HttpResponseMessage: DotNet HttpResponseMessage;
        lTxtEnvelopeXML: Text;
        lTxtXML: Text;
        lTxtTag: Text;
        XmlNode: DotNet XmlNode;
        XmlNodeList: DotNet XmlNodeList;
        XmlNodeChild: DotNet XmlNode;
        lIntIndex: Integer;
        XmlDocument: DotNet XmlDocument;
        XmlNSM: DotNet XmlNamespaceManager;
        XmlNameTable: DotNet XmlNameTable;
        out: OutStream;
        MyFile: File;
        blnLoop: Boolean;
        XmlDocumentChild: DotNet XmlDocument;
        XmlDocChild: Codeunit "XML DOM Management";
        XmlDoc: Codeunit "XML DOM Management";
        lTxtFields: BigText;
        lTxtValues: BigText;
        lTxtOperators: BigText;
        lBlnLoop: Boolean;
        XmlAttributes: DotNet XmlAttributeCollection;
        lTxtValues2: BigText;
        lTxtXmlHeaderTag: Text;
        lIntPosition: Integer;
    begin
        IF gIdSessionAdijedWS = '' THEN
            LoginAdijedWS;

        Parameters := Parameters.SortedDictionary();
        Parameters.Add('baseurl', 'http://' + gRecAdiutoSetup."Ip Address" + ':' + FORMAT(gRecAdiutoSetup.Port));
        Parameters.Add('path', '/adiJed/services/SDKService');
        Parameters.Add('restmethod', 'POST');
        Parameters.Add('ContentType', 'text/xml; charset=utf-8');
        Parameters.Add('SOAPAction', 'executeQueryWithRightandID');

        lTxtContent.ADDTEXT('<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
                       '<soap:Body><ns1:executeQueryWithRightandID xmlns:ns1="http://ws.adiJed">' +
                       '<ns1:session-id>' + gIdSessionAdijedWS + '</ns1:session-id>' +
                       '<ns1:family-id>' + FORMAT(pRecAdiutoSetupDetail."Id Family Document") + '</ns1:family-id>');

        ElectrInvoiceGetSearchFieldsIDValuesParameters(pRecAdiutoSetupDetail, lTxtFields, lTxtValues, lTxtOperators, lTxtValues2);

        lTxtContent.ADDTEXT(lTxtFields);
        lTxtContent.ADDTEXT(lTxtValues);
        lTxtContent.ADDTEXT(lTxtValues2);
        lTxtContent.ADDTEXT(lTxtOperators);
        lTxtContent.ADDTEXT('<ns1:auth></ns1:auth>');
        lTxtContent.ADDTEXT('<ns1:links>false</ns1:links>');
        lTxtContent.ADDTEXT('<ns1:attachments>false</ns1:attachments>');
        lTxtContent.ADDTEXT('</ns1:executeQueryWithRightandID></soap:Body></soap:Envelope>');

        Parameters.Add('httpcontent', lTxtContent);

        CallRESTWebService(Parameters, HttpResponseMessage);
        lTxtEnvelopeXML := HttpResponseMessage.Content.ReadAsStringAsync.Result;
        IF HttpResponseMessage.StatusCode <> 200 THEN BEGIN
            LogoutAdijedWS;
            ERROR('Http Error ' + ' ' + FORMAT(HttpResponseMessage.StatusCode) + ': ' + lTxtEnvelopeXML);
        END;

        LogoutAdijedWS;

        lTxtXML := '';
        lBlnLoop := TRUE;

        XmlDoc.LoadXMLDocumentFromText(lTxtEnvelopeXML, XmlDocument);
        //>BC-MIG
        /*
                XmlDoc.LoadXMLDocumentFromText(lTxtEnvelopeXML, XmlDocument);
                REPEAT
                    IF ISNULL(XmlDocument) = FALSE THEN BEGIN
                        lTxtXML := XmlDocument.Value();
                        XmlDocument := XmlDocument.FirstChild();
                    END;
                    IF ISNULL(XmlDocument) = TRUE THEN
                        lBlnLoop := FALSE;
                UNTIL lBlnLoop = FALSE;
        */
        XmlDocument.GetElementsByTagName('famiglia');
        lTxtXML := XmlDocument.InnerText();
        //<BC-MIG

        EXIT(lTxtXML);
    end;

    local procedure ElectrInvoiceGetSearchFieldsIDValuesParameters(pRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED"; var pTxtFields: BigText; var pTxtValues: BigText; var pTxtOperators: BigText; var pTxtValues2: BigText)
    var
        lRecAdiutoSetupDetailLines: Record "Adiuto Setup Detail Lines ED";
        lRecAdiutoSetup: Record "Adiuto Setup ED";
        lRecCompanyInformation: Record "Company Information";
    begin
        IF NOT lRecAdiutoSetup.GET THEN
            ERROR(Text002);

        pTxtFields.ADDTEXT('<ns1:fields-id>');
        pTxtValues.ADDTEXT('<ns1:values1>');
        pTxtValues2.ADDTEXT('<ns1:values2>');
        pTxtOperators.ADDTEXT('<ns1:operators>');

        pTxtFields.ADDTEXT('<ns1:int>' + FORMAT(pRecAdiutoSetupDetail."El. Doc. Status Fld. Id") + '</ns1:int>');
        pTxtValues.ADDTEXT('<ns1:string>' + lRecAdiutoSetup."Electr. Doc. to Import Status" + '</ns1:string>');
        pTxtValues2.ADDTEXT('<ns1:string></ns1:string>');
        pTxtOperators.ADDTEXT('<ns1:string>=</ns1:string>');

        //>JM-FM20180416
        IF lRecAdiutoSetup."Electr. Doc. B2B Value" <> '' THEN BEGIN
            IF pRecAdiutoSetupDetail."El. Doc. B2B Fld. Id" <> 0 THEN BEGIN
                pTxtFields.ADDTEXT('<ns1:int>' + FORMAT(pRecAdiutoSetupDetail."El. Doc. B2B Fld. Id") + '</ns1:int>');
                pTxtValues.ADDTEXT('<ns1:string>' + lRecAdiutoSetup."Electr. Doc. B2B Value" + '</ns1:string>');
                pTxtValues2.ADDTEXT('<ns1:string></ns1:string>');
                pTxtOperators.ADDTEXT('<ns1:string>=</ns1:string>');
            END;
        END;
        //<JM-FM20180416


        /*
        IF lRecAdiutoSetup."Field Company Id" <> 0 THEN BEGIN
          pTxtFields.ADDTEXT('<ns1:int>' + FORMAT(lRecAdiutoSetup."Field Company Id") + '</ns1:int>');
          pTxtValues.ADDTEXT('<ns1:string>' + lRecAdiutoSetup."Value Field Company" + '</ns1:string>');
          pTxtValues2.ADDTEXT('<ns1:string></ns1:string>');
          pTxtOperators.ADDTEXT('<ns1:string>=</ns1:string>');
        END;
        */

        IF pRecAdiutoSetupDetail."El. Doc. VAT Reg. Fld. Id" <> 0 THEN BEGIN
            lRecCompanyInformation.GET;
            pTxtFields.ADDTEXT('<ns1:int>' + FORMAT(pRecAdiutoSetupDetail."El. Doc. VAT Reg. Fld. Id") + '</ns1:int>');
            pTxtValues.ADDTEXT('<ns1:string>' + lRecCompanyInformation."VAT Registration No." + '</ns1:string>');
            pTxtValues2.ADDTEXT('<ns1:string></ns1:string>');
            pTxtOperators.ADDTEXT('<ns1:string>=</ns1:string>');
        END;


        pTxtFields.ADDTEXT('</ns1:fields-id>');
        pTxtValues.ADDTEXT('</ns1:values1>');
        pTxtValues2.ADDTEXT('</ns1:values2>');
        pTxtOperators.ADDTEXT('</ns1:operators>');

    end;

    procedure ElectrInvoiceGetDocuments(pRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED"; var pTmpRecAdiutoElectrInv: Record "Adiuto Electr. Doc." temporary)
    var
        lIntIndex: Integer;
        Parameters: DotNet SortedDictionary_Of_T_U;
        lTxtContent: BigText;
        HttpResponseMessage: DotNet HttpResponseMessage;
        lRecAdiutoSetupDetailLines: Record "Adiuto Setup Detail Lines ED";
        lTxtFields: BigText;
        lTxtValues: BigText;
        lTxtOperators: BigText;
        lTxtXML: Text;
        lTxtEnvelopeXML: Text;
        XmlDocument: DotNet XmlDocument;
        XmlNode: DotNet XmlNode;
        XmlDoc: Codeunit "XML DOM Management";
        XmlAttributes: DotNet XmlAttributeCollection;
        XmlNodeList: DotNet XmlNodeList;
        XmlNodeListChild: DotNet XmlNodeList;
        XmlNodeChild: DotNet XmlNode;
        lIntIndexChild: Integer;
        lTxtFilename: Text;
        lCduFileManagement: Codeunit "File Management";
        lTxtBarcode: Text;
        lTxtXmlHeaderTag: Text;
        lIntPosition: Integer;
    begin
        pTmpRecAdiutoElectrInv.DELETEALL;
        lTxtXML := '';
        lTxtEnvelopeXML := ElectrInvoiceExecuteQuery(pRecAdiutoSetupDetail);
        IF lTxtEnvelopeXML = '' THEN
            EXIT;

        //>BC-MIG
        //Normalizzazione XML
        lTxtXmlHeaderTag := '?>';
        REPEAT
            //Controllo Header
            lIntPosition := STRPOS(lTxtEnvelopeXML, lTxtXmlHeaderTag);
            IF lIntPosition > 0 THEN
                lTxtEnvelopeXML := COPYSTR(lTxtEnvelopeXML, lIntPosition + STRLEN(lTxtXmlHeaderTag));
            lTxtEnvelopeXML := DELCHR(lTxtEnvelopeXML, '<>', ' ');
        UNTIL lIntPosition <= 0;

        lTxtEnvelopeXML := DELCHR(lTxtEnvelopeXML, '<>', ' ');

        //<BC-MIG
        XmlDoc.LoadXMLDocumentFromText(lTxtEnvelopeXML, XmlDocument);
        //XmlDocument.FirstChild;

        XmlNodeList := XmlDocument.GetElementsByTagName('famiglia');
        lTxtBarcode := XmlDocument.InnerText();

        XmlNodeList := XmlDocument.GetElementsByTagName('record');
        lTxtBarcode := '';
        IF XmlNodeList.Count > 0 THEN BEGIN //<record></record>
            FOR lIntIndex := 0 TO XmlNodeList.Count DO BEGIN
                XmlNode := XmlNodeList.Item(lIntIndex);
                IF ISNULL(XmlNode) = FALSE THEN BEGIN
                    XmlNodeListChild := XmlNode.ChildNodes; //<dato ..></dato>
                    IF XmlNodeListChild.Count > 0 THEN BEGIN
                        lTxtXML := '';
                        FOR lIntIndexChild := 0 TO (XmlNodeListChild.Count - 1) DO BEGIN
                            XmlNodeChild := XmlNodeListChild.Item(lIntIndexChild);
                            IF ISNULL(XmlNodeChild) = FALSE THEN BEGIN
                                XmlAttributes := XmlNodeChild.Attributes;
                                IF UPPERCASE(XmlAttributes.GetNamedItem('nome').Value) = UPPERCASE('idUnivoco') THEN
                                    lTxtXML := XmlNodeChild.InnerText;
                                IF UPPERCASE(XmlAttributes.GetNamedItem('nome').Value) = UPPERCASE('nomeFile') THEN
                                    lTxtFilename := XmlNodeChild.InnerText;
                                IF UPPERCASE(XmlAttributes.GetNamedItem('nome').Value) = UPPERCASE(pRecAdiutoSetupDetail."El. Doc. Barcode Fld. Name") THEN
                                    lTxtBarcode := XmlNodeChild.InnerText;
                            END;
                        END;
                        IF lTxtXML <> '' THEN BEGIN
                            pTmpRecAdiutoElectrInv.INIT;
                            pTmpRecAdiutoElectrInv.IdUnivoco := lTxtXML;
                            pTmpRecAdiutoElectrInv."File Name" := lCduFileManagement.GetFileNameWithoutExtension(lTxtFilename) + '.' + pRecAdiutoSetupDetail."File Extension";
                            pTmpRecAdiutoElectrInv.Barcode := lTxtBarcode;
                            pTmpRecAdiutoElectrInv.INSERT;
                        END;
                    END;
                END;
            END;
        END;
    end;

    procedure InsertDocumentForElectrInvoice(pTxtFileName: Text; pTxtFileContent: Text; pRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED"; pRefRecord: RecordRef; pTxtTransmit: Text; pTxtVATRegNo: Text; pTxtProgressive: Text; pTxtCustCompName: Text) Result: Integer
    var
        Convert: DotNet Convert;
        ClientFile: DotNet File;
        lIntNumFields: Integer;
        lIntIndex: Integer;
        lCduFileManagement: Codeunit "File Management";
        HttpClient: DotNet HttpClient;
        HttpContent: DotNet HttpContent;
        Parameters: DotNet SortedDictionary_Of_T_U;
        HttpResponseMessage: DotNet HttpResponseMessage;
        lTxtContent: BigText;
        lTxtEnvelopeXML: Text;
        lTxtFields: BigText;
        lTxtValues: BigText;
        lTxtOperators: BigText;
        lTxtResult: Text;
    begin
        LoginAdijedWS;

        IF NOT gRecAdiutoSetup.GET THEN
            ERROR(Text002);

        Parameters := Parameters.SortedDictionary();
        Parameters.Add('baseurl', 'http://' + gRecAdiutoSetup."Ip Address" + ':' + FORMAT(gRecAdiutoSetup.Port));
        Parameters.Add('path', '/adiJed/services/AdiJedWS');
        Parameters.Add('restmethod', 'POST');
        Parameters.Add('ContentType', 'text/xml; charset=utf-8');
        Parameters.Add('SOAPAction', 'insertDocument');

        lTxtContent.ADDTEXT('<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
                            '<soap:Body><ns1:insertDocument xmlns:ns1="http://ws.adiJed">' +
                            '<ns1:session-id>' + gIdSessionAdijedWS + '</ns1:session-id>');

        lTxtContent.ADDTEXT('<ns1:file>' + pTxtFileContent + '</ns1:file>' +
                            '<ns1:filename>' + pTxtFileName + '</ns1:filename>');

        lTxtContent.ADDTEXT('<ns1:family-id>' + FORMAT(pRecAdiutoSetupDetail."Id Family Document") + '</ns1:family-id>');

        GetInsertFieldsIdValuesParametersForElectrInvoice(pRecAdiutoSetupDetail, pRefRecord, lTxtFields, lTxtValues, pTxtTransmit, pTxtVATRegNo, pTxtProgressive, pTxtCustCompName);

        lTxtContent.ADDTEXT(lTxtFields);
        lTxtContent.ADDTEXT(lTxtValues);

        lTxtContent.ADDTEXT('</ns1:insertDocument></soap:Body></soap:Envelope>');

        Parameters.Add('httpcontent', lTxtContent);

        CallRESTWebService(Parameters, HttpResponseMessage);
        lTxtEnvelopeXML := HttpResponseMessage.Content.ReadAsStringAsync.Result;
        IF HttpResponseMessage.StatusCode <> 200 THEN BEGIN
            LogoutAdijedWS;
            ERROR('Http Error ' + ' ' + FORMAT(HttpResponseMessage.StatusCode) + ': ' + lTxtEnvelopeXML);
        END;

        GetXmlTagValue(lTxtEnvelopeXML, 'ns1:newDocumentIndexes', lTxtResult);
        EVALUATE(Result, lTxtResult);

        IF Result < 0 THEN BEGIN
            LogoutAdijedWS;
            ERROR(Text004);
        END;

        LogoutAdijedWS;
    end;

    local procedure GetInsertFieldsIdValuesParametersForElectrInvoice(pRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED"; pRefRecord: RecordRef; var pTxtFields: BigText; var pTxtValues: BigText; pTxtTransmit: Text; pTxtVATRegNo: Text; pTxtProgressive: Text; pTxtCustCompName: Text)
    var
        lRecAdiutoSetupDetailLines: Record "Adiuto Setup Detail Lines ED";
    begin
        pTxtFields.ADDTEXT('<ns1:fields-id>');
        pTxtValues.ADDTEXT('<ns1:values>');

        lRecAdiutoSetupDetailLines.RESET;
        lRecAdiutoSetupDetailLines.SETRANGE("Primary Key", pRecAdiutoSetupDetail."Primary Key");
        lRecAdiutoSetupDetailLines.SETRANGE("Line No.", pRecAdiutoSetupDetail."Line No.");
        lRecAdiutoSetupDetailLines.SETRANGE("Use for Insertion", TRUE);
        IF lRecAdiutoSetupDetailLines.FINDSET THEN BEGIN
            REPEAT
                pTxtFields.ADDTEXT('<ns1:int>' + FORMAT(lRecAdiutoSetupDetailLines."Adiuto Field Id") + '</ns1:int>');
                pTxtValues.ADDTEXT('<ns1:string>' + GetFieldValue(pRefRecord, lRecAdiutoSetupDetailLines) + '</ns1:string>');
            UNTIL lRecAdiutoSetupDetailLines.NEXT = 0;
        END;

        IF gRecAdiutoSetup."Field Company Id" <> 0 THEN BEGIN
            pTxtFields.ADDTEXT('<ns1:int>' + FORMAT(gRecAdiutoSetup."Field Company Id") + '</ns1:int>');
            pTxtValues.ADDTEXT('<ns1:string>' + gRecAdiutoSetup."Value Field Company" + '</ns1:string>');
        END;

        IF (pRecAdiutoSetupDetail."El. Doc. Trasmit. Fld. Id" > 0) AND
           (pTxtTransmit <> '') THEN BEGIN
            pTxtFields.ADDTEXT('<ns1:int>' + FORMAT(pRecAdiutoSetupDetail."El. Doc. Trasmit. Fld. Id") + '</ns1:int>');
            pTxtValues.ADDTEXT('<ns1:string>' + pTxtTransmit + '</ns1:string>');
        END;

        IF (pRecAdiutoSetupDetail."El. Doc. Progressive Fld. Id" > 0) AND
           (pTxtProgressive <> '') THEN BEGIN
            pTxtFields.ADDTEXT('<ns1:int>' + FORMAT(pRecAdiutoSetupDetail."El. Doc. Progressive Fld. Id") + '</ns1:int>');
            pTxtValues.ADDTEXT('<ns1:string>' + pTxtProgressive + '</ns1:string>');
        END;

        IF (pRecAdiutoSetupDetail."El. Doc. VAT Reg. Fld. Id" > 0) AND
           (pTxtVATRegNo <> '') THEN BEGIN
            pTxtFields.ADDTEXT('<ns1:int>' + FORMAT(pRecAdiutoSetupDetail."El. Doc. VAT Reg. Fld. Id") + '</ns1:int>');
            pTxtValues.ADDTEXT('<ns1:string>' + pTxtVATRegNo + '</ns1:string>');
        END;

        IF (pRecAdiutoSetupDetail."El. Doc. Cust. Comp. Fld. Id" > 0) AND
           (pTxtCustCompName <> '') THEN BEGIN
            pTxtFields.ADDTEXT('<ns1:int>' + FORMAT(pRecAdiutoSetupDetail."El. Doc. Cust. Comp. Fld. Id") + '</ns1:int>');
            pTxtValues.ADDTEXT('<ns1:string>' + pTxtCustCompName + '</ns1:string>');
        END;

        pTxtFields.ADDTEXT('</ns1:fields-id>');
        pTxtValues.ADDTEXT('</ns1:values>');
    end;

    local procedure GetInsertFieldsIdValuesParameters(pRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED"; pRefRecord: RecordRef; var pTxtFields: BigText; var pTxtValues: BigText)
    var
        lRecAdiutoSetupDetailLines: Record "Adiuto Setup Detail Lines ED";
    begin
        pTxtFields.ADDTEXT('<ns1:fields-id>');
        pTxtValues.ADDTEXT('<ns1:values>');

        lRecAdiutoSetupDetailLines.RESET;
        lRecAdiutoSetupDetailLines.SETRANGE("Primary Key", pRecAdiutoSetupDetail."Primary Key");
        lRecAdiutoSetupDetailLines.SETRANGE("Line No.", pRecAdiutoSetupDetail."Line No.");
        lRecAdiutoSetupDetailLines.SETRANGE("Use for Insertion", TRUE);
        IF lRecAdiutoSetupDetailLines.FINDSET THEN BEGIN
            REPEAT
                pTxtFields.ADDTEXT('<ns1:int>' + FORMAT(lRecAdiutoSetupDetailLines."Adiuto Field Id") + '</ns1:int>');
                pTxtValues.ADDTEXT('<ns1:string>' + GetFieldValue(pRefRecord, lRecAdiutoSetupDetailLines) + '</ns1:string>');
            UNTIL lRecAdiutoSetupDetailLines.NEXT = 0;
        END;

        IF gRecAdiutoSetup."Field Company Id" <> 0 THEN BEGIN
            pTxtFields.ADDTEXT('<ns1:int>' + FORMAT(gRecAdiutoSetup."Field Company Id") + '</ns1:int>');
            pTxtValues.ADDTEXT('<ns1:string>' + gRecAdiutoSetup."Value Field Company" + '</ns1:string>');
        END;

        pTxtFields.ADDTEXT('</ns1:fields-id>');
        pTxtValues.ADDTEXT('</ns1:values>');
    end;
}

