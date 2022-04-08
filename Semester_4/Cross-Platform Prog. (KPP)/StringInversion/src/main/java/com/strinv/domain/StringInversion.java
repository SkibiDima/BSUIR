package com.strinv.domain;

import java.util.Objects;

public class StringInversion {

    private String string;

    public StringInversion(String ent_string){
        this.string = ent_string;
    }

    public void setString(String ent_string){
        this.string = ent_string;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        StringInversion that = (StringInversion) o;
        return Objects.equals(string, that.string);
    }

    @Override
    public int hashCode() {
        return Objects.hash(string);
    }

    public String getString(){return string;}
}
