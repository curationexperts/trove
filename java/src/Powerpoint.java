import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

import java.util.Scanner;
import org.apache.commons.io.IOUtils;

import com.google.gson.Gson;

import org.apache.poi.xslf.usermodel.SlideLayout;
import org.apache.poi.xslf.usermodel.XMLSlideShow;
import org.apache.poi.xslf.usermodel.XSLFPictureData;
import org.apache.poi.xslf.usermodel.XSLFPictureShape;
import org.apache.poi.xslf.usermodel.XSLFSlide;
import org.apache.poi.xslf.usermodel.XSLFSlideLayout;
import org.apache.poi.xslf.usermodel.XSLFSlideMaster;
import org.apache.poi.xslf.usermodel.XSLFTextBox;
import org.apache.poi.xslf.usermodel.XSLFTextParagraph;
import org.apache.poi.xslf.usermodel.XSLFTextRun;
import org.apache.poi.xslf.usermodel.XSLFTextShape;
import org.apache.poi.xslf.usermodel.TextAlign;


// For reference:
// POI - Apache OpenOffice API
// http://poi.apache.org/slideshow/xslf-cookbook.html
// http://poi.apache.org/apidocs/index.html
// GSON - Google JSON
// https://sites.google.com/site/gson/gson-user-guide#TOC-Using-Gson
// http://google-gson.googlecode.com/svn/trunk/gson/docs/javadocs/index.html

// For developer debugging statements, you can use:
// System.err.println(message);
// (since we're using System.out for the data stream)

// This reads a series of JSON objects from STDIN
/*
  CollectionData object example (one per export)
  {
    "collectionName":"The Collection Title",
    "description":["First description element","Another Description","And so on..."],
    "imageCount":no_of_slide_images
    "pptExportFile":"/local/server/path/to/ouput.pptx"
  }

  ImageData object example (one per each image in exported collection)
  {
    "title":"Image title from image metadata",
    "creator":["Photographer/Painter/Artists/Architect name","Can be multiple... or empty"],
    "date":["Creation_date from metadata","Could be multiple... or empty"],
    "description":["First description element","Another Description","Could be multiple... or empty"],
    "imagePath":"/local/server/path/to/image",
    "x":left-offset, y":top-offest, "width": image-width, "height": image-height} // use to center image on a 720 x 540 slide
  }
*/

public class Powerpoint {

  // Prefix your error message with this string
  // so that the ruby code knows it's an error.
  private static final String ERROR = "ERROR: ";

    static class CollectionData {
  	  public String collectionTitle;
  	  public String collectionType;
  	  public String creator;
  	  public String uri;
  	  public String[] description;

  	  public int imageCount;
      public String pptExportFile;

  	  public CollectionData() {
  	    // no-args constructor
  	  }
  	}

    static class ImageData {
  	  public String   title;
  	  public String[] creator;
  	  public String[] description;
  	  public String[] date;

      public String imagePath;
      public int x;
      public int y;
      public int height;
      public int width;

      public ImageData() {
        // no-args constructor
      }
    }

  public static void main(String[] args) {
    XMLSlideShow ppt = new XMLSlideShow();

    // Collect data from the ruby process and use
    // it to generate the powerpoint file.
    Scanner scan = new Scanner(System.in);

    String collection_json = scan.nextLine();
    Gson gson = new Gson();
    CollectionData collection = gson.fromJson(collection_json, CollectionData.class);

    addTitleSlide(ppt, collection);

    int numberOfImageSlides = collection.imageCount;
    for(int i=0; i<numberOfImageSlides; i++) {
      String image_json = scan.nextLine();
      ImageData img = gson.fromJson(image_json, ImageData.class);

      try {
        // addMetadataSlide(ppt, img); TODO: create method to display refactored json metadata slides
        addImageSlide(ppt, img);
      } catch(FileNotFoundException ex) {
        System.out.println(ERROR + ex.getMessage());
        return;
      } catch(IOException ex) {
        System.out.println(ERROR + ex.getMessage());
        return;
      }
    }

    String outputFileName = collection.pptExportFile;
    System.out.println(writePptFile(ppt, outputFileName));
  }

  private static void addTitleSlide(XMLSlideShow ppt, CollectionData collection) {
    XSLFSlideMaster defaultMaster = ppt.getSlideMasters()[0];
    XSLFSlideLayout titleBodyLayout = defaultMaster.getLayout(SlideLayout.TITLE_AND_CONTENT);
    XSLFSlide titleSlide = ppt.createSlide(titleBodyLayout);

    // Replace placeholder text with our data
    XSLFTextShape[] placeholders = titleSlide.getPlaceholders();
    placeholders[0].clearText();
	XSLFTextParagraph header = placeholders[0].addNewTextParagraph();
    header.setLevel(0);
    header.setBullet(false);
	header.setTextAlign(TextAlign.LEFT);
	XSLFTextRun t1 = header.addNewTextRun();	
	t1.setText(maxText(collection.collectionTitle, 100));
	t1.setBold(true);
	t1.setFontSize(titleFontSize(collection.collectionTitle));

    placeholders[1].clearText();
    XSLFTextParagraph para = placeholders[1].addNewTextParagraph();
    para.setLevel(0);
    para.setBullet(true);

    // Add '\r' to the Strings so they'll be separate bullet points
    StringBuilder desc = new StringBuilder();
    for(int j=0; j<collection.description.length; j++) {
      desc.append(collection.description[j]);
      if (collection.description[j].length() > 0 && j < collection.description.length) {
        // don't apppend to the last one.
        desc.append('\r');
      }
    }
	
    XSLFTextRun r1 = para.addNewTextRun();
	r1.setText(maxText( desc.toString(), 900 ));
	r1.setFontSize(bodyFontSize( desc.toString() ));

    for(int j=2; j<placeholders.length; j++) {
      placeholders[j].clearText();
    }
  }

  private static void addImageSlide(XMLSlideShow ppt, ImageData image) throws FileNotFoundException, IOException {
    XSLFSlide slide = ppt.createSlide();
    if (image.imagePath.length() > 0) {
      byte[] pictureData = IOUtils.toByteArray(new FileInputStream(image.imagePath));
      int idx = ppt.addPicture(pictureData, XSLFPictureData.PICTURE_TYPE_PNG);
      XSLFPictureShape pic = slide.createPicture(idx);
      pic.setAnchor(new java.awt.Rectangle(image.x, image.y, image.width, image.height));
    }
  }

  private static String writePptFile(XMLSlideShow ppt, String outputFileName) {
    FileOutputStream out = null;
    try {
      out = new FileOutputStream(outputFileName);
      ppt.write(out);
    } catch(FileNotFoundException ex) {
      return ERROR + ex.getMessage();
    } catch(IOException ex) {
      return ERROR + ex.getMessage();
    } finally {
      if(out != null) {
        try {
          out.close();
        } catch(IOException ex) {
        }
      }
    }
    return outputFileName;
  }
  
  private static int bodyFontSize(String s) {
    int size = s.length();
	if      (size < 300) { return 28; }
    else if (size < 500) { return 24; }
    else                 { return 20; } // up to 900 characters in length works nicely
  }

  private static int titleFontSize(String s) {
    int size = s.length();
	if      (size < 45)  { return 40; }
    else if (size < 75)  { return 32; }
    else                 { return 28; } // up to 100 characters in length works nicely
  }

  private static String maxText(String s, int max_length) {
	  int size = s.length();
	  int best_space = s.substring(0, Math.min(size,max_length)).lastIndexOf(' ');
	  
	  // just return the string if it's short enough
	  if (size < max_length) { return s; }  
	  // otherwise, try to break on a space if there's one within the last 15 characters
	  else if (best_space > max_length-15) { return s.substring(0, best_space) + "..."; } 
	  // or just chomp it if there's no space near the end to break on
	  else { return s.substring(0, max_length) + "..."; } 
  }

}
