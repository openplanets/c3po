package com.petpet.c3po.adaptor.tika;

import com.petpet.c3po.api.adaptor.AbstractAdaptor;
import com.petpet.c3po.api.dao.ReadOnlyCache;
import com.petpet.c3po.api.model.Element;
import com.petpet.c3po.api.model.Property;
import com.petpet.c3po.api.model.Source;
import com.petpet.c3po.api.model.helper.MetadataRecord;
import com.petpet.c3po.utils.DataHelper;
import org.junit.Before;
import org.junit.Test;

import java.util.HashMap;
import java.util.Map;

import static org.fest.assertions.Assertions.assertThat;

/**
 * This is a rough, unit-ish test for a TIKAAdaptor, that aims to test the main functionality
 * of the TIKAAdaptor and related -ResultParser and -Helper via input-output-tests for the
 * parseElement method.
 */
public class TIKAAdaptorTest {

    private String testPdfName;
    private String testPdfResourceName;
    private String testPdfData_v1_3;
    private Map<String, String> expectedProps_v1_3;

    private static class MockCache implements ReadOnlyCache {

        Map<String, Property> propDict = new HashMap<String, Property>();
        Map<String, Source> sourceDict = new HashMap<String, Source>();
        Map<String, Object> objectDict = new HashMap<String, Object>();

        @Override
        public Property getProperty(String key) {
            Property prop = this.propDict.get(key);
            if (prop != null) return prop;
            return createProperty(key);
        }

        private Property createProperty( String key ) {
            Property p = new Property(key);
            p.setType(DataHelper.getPropertyType(key));
            this.propDict.put( key, p );
            return p;
        }

        @Override
        public Source getSource(String name, String version) {
            Source source = this.sourceDict.get(name + ":" + version);
            if (source != null) return source;
            return createSource(name, version);
        }

         private Source createSource( String name, String version ) {
            Source s = new Source( name, version );
            this.sourceDict.put( name + ":" + version, s );
            return s;
          }

        @Override
        public Object getObject(Object key) {
            return this.objectDict.get(key);
        }
    }

    @Before
    public void buildTestPdf_v1_3() {
        expectedProps_v1_3 = new HashMap<String, String>();
        testPdfName = "testPdfName";
        testPdfData_v1_3 = "Author: Administrator\n";
        expectedProps_v1_3.put("author", "Administrator");
        testPdfData_v1_3 += "Content-Length: 4755\n";
        expectedProps_v1_3.put("size", "4755");
        testPdfData_v1_3 += "Content-Type: application/pdf\n";
        expectedProps_v1_3.put("mimetype", "application/pdf");
        testPdfData_v1_3 += "Creation-Date: 2000-02-10T14:26:30Z\n";
        expectedProps_v1_3.put("created", "2000-02-10T14:26:30Z");
        testPdfData_v1_3 += "Last-Modified: 2000-04-27T21:13:20Z\n";
        testPdfData_v1_3 += "Last-Save-Date: 2000-04-27T21:13:20Z\n";
        testPdfData_v1_3 += "created: Thu Feb 10 14:26:30 GMT 2000\n";
        testPdfData_v1_3 += "creator: Administrator\n";
        testPdfData_v1_3 += "date: 2000-04-27T21:13:20Z\n";
        testPdfData_v1_3 += "dc:creator: Administrator\n";
        testPdfData_v1_3 += "dc:title: WESTERN SAND & GRAVEL V. SOL (MSHA)     (93020298)\n";
        expectedProps_v1_3.put("title", "WESTERN SAND & GRAVEL V. SOL (MSHA)     (93020298)");
        testPdfData_v1_3 += "dcterms:created: 2000-02-10T14:26:30Z\n";
        testPdfData_v1_3 += "dcterms:modified: 2000-04-27T21:13:20Z\n";
        testPdfData_v1_3 += "meta:author: Administrator\n";
        testPdfData_v1_3 += "meta:creation-date: 2000-02-10T14:26:30Z\n";
        testPdfData_v1_3 += "meta:save-date: 2000-04-27T21:13:20Z\n";
        testPdfData_v1_3 += "modified: 2000-04-27T21:13:20Z\n";
        testPdfData_v1_3 += "producer: Acrobat PDFWriter 4.0 for Windows NT\n";
        testPdfData_v1_3 += "resourceName: 000020.pdf\n";
        testPdfResourceName = "000020.pdf";
        testPdfData_v1_3 += "title: WESTERN SAND & GRAVEL V. SOL (MSHA)     (93020298)\n";
        testPdfData_v1_3 += "xmp:CreatorTool: Microsoft Word - 93020298.TXT\n";
        testPdfData_v1_3 += "xmpTPg:NPages: 2";
    }

    @Test
    public void testParseElementV1_3() {
        // TODO: title + dc_title merge into title, hence off by one; is that what we want?
        int expectedPropSize = expectedProps_v1_3.size() + 1;
        parseElement(testPdfData_v1_3, expectedProps_v1_3, expectedPropSize);
    }

    public void parseElement(String testData, Map<String, String> expectedProps, int expectedPropSize) {
        AbstractAdaptor adaptor = new TIKAAdaptor();

        adaptor.setCache(new MockCache());

        TIKAHelper.init();
        DataHelper.init();
        Element result = adaptor.parseElement(testPdfName, testData);

        // result name comes from resourceName
        assertThat(result.getName()).isEqualTo(testPdfResourceName);
        assertThat(result.getMetadata()).hasSize(expectedPropSize);
        for (MetadataRecord record : result.getMetadata()) {
            assertThat(expectedProps.values().contains(record.getValue()));
        }
    }
}
