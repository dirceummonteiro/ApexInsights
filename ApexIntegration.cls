private static String getToken() {
    String token = '';
    String endpoint = '';
    Token result = new Token();

    Integracao__mdt configToken = [SELECT Id, Endpoint__c, ClientId__c, ClientSecret__c, Scope__c, GrantType__c FROM Integracao__mdt WHERE MasterLabel = 'TokenBanco'];
    if (configToken == null)      return token;

    String payload = 'client_id=' + EncodingUtil.urlEncode (configToken.clientId__c, 'UTF-8') + '&client_secret=' + EncodingUtil.urlEncode (configToken.clientSecret__c, 'UTF-8') + '&scope=' + EncodingUtil.urlEncode (configToken.Scope__c, 'UTF-8') + '&grant_type=' +  EncodingUtil.urlEncode (configToken.GrantType__c, 'UTF-8');
    
    endpoint = configToken.Endpoint__c;
    Map<String, String> header = new Map<String, String>();
    header.put('Content-Type', 'application/x-www-form-urlencoded');
    
    HttpResponse response = Util.callout(endpoint, 'POST', header, payload);

    if (response.getStatusCode() == 200) {
        try {
            result = (Token) JSON.deserialize(response.getBody(), Token.class);
            token = result.access_token;
    
        } catch (Exception ex) {
            System.debug('ERROR! : ' + ex.getMessage());
            return token;
        }
    }

    return token;
}




public static HttpResponse callout(String endpoint, String method, map<String, String> header, String body) {
    Http ht =  new Http();
    HttpRequest request = new HttpRequest();
    request.setTimeout(60000);
    request.setEndpoint(endpoint);
    request.setMethod(method);
    for(String key : header.keySet()){
        request.setHeader(key, header.get(key));
    }
    if(body != null){
        request.setBody(body);
    }
    return  ht.send(request);
}