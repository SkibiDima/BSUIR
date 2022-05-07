package com.strinv.cache;

import lombok.AllArgsConstructor;
import org.apache.logging.log4j.Level;
import org.springframework.stereotype.Component;

import com.strinv.domain.StringInversion;
import com.strinv.logger.appLogger;

import java.util.HashMap;

@AllArgsConstructor
@Component
public class StringCache {

    private  HashMap<String, StringInversion> stringsMap ;

    public void add(StringInversion params,  String key) {
        if (!stringsMap.containsKey(key)) {
            stringsMap.put(key, params);
            appLogger.setLog(Level.INFO, "String " + params + " @" + key + " added to map");
        }
    }

    public boolean isCached(String key){
        return stringsMap.containsKey(key);
    }

    public  StringInversion find(String key) {
        if (stringsMap.containsKey(key)) {
            appLogger.setLog(Level.INFO, "String " + key + " found in map");
            return stringsMap.get(key);
        }

        appLogger.setLog(Level.INFO, "String " + key + " not found in map");
        return null;
    }
}
