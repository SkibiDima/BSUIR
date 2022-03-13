package com.strinv.domain;

public class Results {
    private final String string;

    public Results(String req_string){this.string = new StringBuilder(req_string).reverse().toString();}

    public String getString(){return string;}
}
