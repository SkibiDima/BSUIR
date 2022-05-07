package com.strinv.services;

import com.strinv.logger.appLogger;
import com.strinv.cache.StringCache;
import com.strinv.domain.StringInversion;
import lombok.AllArgsConstructor;
import org.apache.logging.log4j.Level;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

@AllArgsConstructor
@Service
public class StringInversionService {

    private StringCache stringsMap;
    private StatCollectorService statCollector;

    public List<StringInversion> inversionStream(Stream<String> stringStream){

        return stringStream.map(this::inversion).collect(Collectors.toCollection(ArrayList::new));
    }

    public StringInversion inversion(String string){

        statCollector.increaseTotalRequests();
        appLogger.setLog(Level.INFO, "Got string");
        if(string.equals("")) {
            statCollector.increaseWrongRequests();
            appLogger.setLog(Level.INFO, "Illegal arguments in StringInversion: empty");
            throw new IllegalArgumentException("Illegal arguments in StringInversion: empty");
        }

        statCollector.addStrings(string);
        if(stringsMap.isCached(string)) {
            appLogger.setLog(Level.INFO, "Inverted");
            return stringsMap.find(string);
        } else {
            StringInversion result = new StringInversion(new StringBuilder(string).reverse().toString());
            stringsMap.add(result, string);
            appLogger.setLog(Level.INFO, "Inverted");
            return result;
        }
    }
}
