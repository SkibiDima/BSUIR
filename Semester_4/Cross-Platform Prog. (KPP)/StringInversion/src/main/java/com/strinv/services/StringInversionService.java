package com.strinv.services;

import com.strinv.logger.appLogger;
import com.strinv.cache.StringCache;
import com.strinv.domain.StringInversion;
import lombok.AllArgsConstructor;
import org.apache.logging.log4j.Level;
import org.springframework.stereotype.Service;

@AllArgsConstructor
@Service
public class StringInversionService {

    private StringCache stringsMap;

    public StringInversion inversion(/*@NotNull*/ String string){

        appLogger.setLog(Level.INFO, "Got string");

        if(string.equals("")) {
            appLogger.setLog(Level.INFO, "Illegal arguments in StringInversion: empty");
            throw new IllegalArgumentException("Illegal arguments in StringInversion: empty");
        }

        StringInversion result = new StringInversion(string);
        if(stringsMap.isCached(string)){
            return stringsMap.find(string);
        }

        result.setString(new StringBuilder(string).reverse().toString());
        stringsMap.add(result, string);

        appLogger.setLog(Level.INFO, "Inverted");
        return result;
    }
}
