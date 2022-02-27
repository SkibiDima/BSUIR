package com.StringInvertor;

public record StringInvertor(String req_string) {

    private String Req_string;

    public StringInvertor(String req_string){
        this.Req_string = req_string;
    }

    public String getReq_string(){
        return Req_string;
    }
}