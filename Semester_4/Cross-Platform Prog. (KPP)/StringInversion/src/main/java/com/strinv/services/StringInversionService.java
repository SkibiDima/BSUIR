package com.strinv.services;

import com.strinv.appLogger;
import com.strinv.domain.StringInversion;
import org.apache.logging.log4j.Level;
import org.springframework.stereotype.Service;

@Service
public class StringInversionService {

    public StringInversion inversion(String string){

        appLogger.setLog(Level.INFO, "Got string");

        if(string.equals("")) {
            appLogger.setLog(Level.INFO, "Illegal arguments in StringInversion: empty");
            throw new IllegalArgumentException("Illegal arguments in StringInversion: empty");
        }

        string = new StringBuilder(string).reverse().toString();
        StringInversion result = new StringInversion(string);
        appLogger.setLog(Level.INFO, "Inverted");
        return result;
    }
}
