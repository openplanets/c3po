/**
 * 
 */
package com.petpet.c3po;

import com.mongodb.BasicDBList;
import com.mongodb.BasicDBObject;
import com.mongodb.DB;
import com.mongodb.DBCollection;
import com.mongodb.DBCursor;
import com.mongodb.Mongo;
import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

import java.io.File;
import java.util.Collection;

import static org.fest.assertions.Assertions.assertThat;

/**
 * @author cfw
 *
 */
public class TikaIntegrationTests {

    private Mongo mongo;
    private static final String DATABASE_NAME = "c3po";
    private static final String TIKA_V1_3_OUTPUT = "/com/petpet/c3po/samples/govdocs/tika1.3-out";

	/**
	 * @throws java.lang.Exception
	 */
	@BeforeClass
	public static void setUpBeforeClass() throws Exception {
	}

	/**
	 * @throws java.lang.Exception
	 */
	@AfterClass
	public static void tearDownAfterClass() throws Exception {
	}

	/**
	 * @throws java.lang.Exception
	 */
	@Before
	public void setUp() throws Exception {
        mongo = new Mongo("localhost");
	}

	/**
	 * @throws java.lang.Exception
	 */
	@After
	public void tearDown() throws Exception {
	}

    @Test
    public final void testTikaVersion1_3() {
        String testFilesPath = this.getClass().getResource(TIKA_V1_3_OUTPUT).getPath();
        String[] args = new String[] {"gather",
                "--collection", "bla",
                "--inputdir", testFilesPath,
                "--type", "TIKA"};
        C3PO.main(args);
        DB mDB = mongo.getDB(DATABASE_NAME);
        assertThat(mDB.collectionExists("elements")).isTrue();

        DBCollection mColl = mDB.getCollection("elements");
        // there's 21 *.tika metadata files
        assertThat(mColl.count()).isEqualTo(21);

        for (File f: new File(testFilesPath).listFiles()) {
            DBCursor query = mColl.find(new BasicDBObject("name", f.getName()));
            // TODO: parse the files, compare the keys/values to what's in the db. this needs domain
            // specific rules!
        }
    }

}
