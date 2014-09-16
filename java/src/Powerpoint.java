import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

import java.util.Scanner;
import org.apache.commons.io.IOUtils;

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


// For reference:
// http://poi.apache.org/slideshow/xslf-cookbook.html
// http://poi.apache.org/apidocs/index.html

// For developer debugging statements, you can use:
// System.err.println(message);
// (since we're using System.out for the data stream)

// This reads a series of lines from STDIN
/*
[outputFileName]
[title]
[numberOfDescriptions]
[description_lines...]
[numberOfImageSlides]
[image_slide_lines...]
*/

// [description_lines...] are descriptions separated by newlines
/*
[description1]
[description2]
[description3]
...
[descriptionN]
*/

// [image_slide_lines...] have this format
/*
[img.imageTitle]
[img.metadata[0]]
[img.metadata[1]]
[img.metadata[2]]
[img.imagePath]
[img.x]
[img.y]
[img.cx]
[img.cy]
*/


public class Powerpoint {

  // Prefix your error message with this string
  // so that the ruby code knows it's an error.
  private static final String ERROR = "ERROR: ";

  public static void main(String[] args) {
    XMLSlideShow ppt = new XMLSlideShow();

    // Collect data from the ruby process and use
    // it to generate the powerpoint file.
    Scanner scan = new Scanner(System.in);
    String outputFileName = scan.nextLine();

    String title = scan.nextLine();
    String[] descriptions = collectDescriptions(scan);
    addTitleSlide(ppt, title, descriptions);

    int numberOfImageSlides = Integer.parseInt(scan.nextLine());
    for(int i=0; i<numberOfImageSlides; i++) {
      ImageData img = ImageData.read(scan);

      try {
        addTitleSlide(ppt, img.imageTitle, img.metadata);
        addImageSlide(ppt, img);
      } catch(FileNotFoundException ex) {
        System.out.println(ERROR + ex.getMessage());
        return;
      } catch(IOException ex) {
        System.out.println(ERROR + ex.getMessage());
        return;
      }
    }

    System.out.println(writePptFile(ppt, outputFileName));
  }

  static class ImageData {
    public int x;
    public int y;
    public int cx;
    public int cy;
    public String imagePath;
    public String imageTitle;
    public String[] metadata;

    public ImageData() {
      this.metadata = new String[3];
    }

    public static ImageData read(Scanner scan) {
      ImageData img = new ImageData();
      img.imageTitle = scan.nextLine();
      img.metadata[0] = scan.nextLine().replaceAll("\\\\r", "\r");
      img.metadata[1] = scan.nextLine().replaceAll("\\\\r", "\r");
      img.metadata[2] = scan.nextLine().replaceAll("\\\\r", "\r");
      img.imagePath = scan.nextLine();
      if (img.imagePath.length() == 0) {
        scan.nextLine();
        scan.nextLine();
        scan.nextLine();
        scan.nextLine();
      } else {
        img.x = Integer.parseInt(scan.nextLine());
        img.y = Integer.parseInt(scan.nextLine());
        img.cx = Integer.parseInt(scan.nextLine());
        img.cy = Integer.parseInt(scan.nextLine());
      }

      return img;
    }
  }


  private static String[] collectDescriptions(Scanner scan) {
    int numberOfDescriptions = Integer.parseInt(scan.nextLine());
    String[] descriptions = new String[numberOfDescriptions];
    for(int k=0; k<numberOfDescriptions; k++) {
      descriptions[k] = scan.nextLine();
    }
    return descriptions;
  }

  private static void addTitleSlide(XMLSlideShow ppt, String title, String[] descriptions) {
    XSLFSlideMaster defaultMaster = ppt.getSlideMasters()[0];
    XSLFSlideLayout titleBodyLayout = defaultMaster.getLayout(SlideLayout.TITLE_AND_CONTENT);
    XSLFSlide titleSlide = ppt.createSlide(titleBodyLayout);

    // Replace placeholder text with our data
    XSLFTextShape[] placeholders = titleSlide.getPlaceholders();
    placeholders[0].setText(title);

    placeholders[1].clearText();
    XSLFTextParagraph para = placeholders[1].addNewTextParagraph();
    para.setLevel(0);
    para.setBullet(true);
    XSLFTextRun r1 = para.addNewTextRun();
    r1.setFontSize(24);

    // Add '\r' to the Strings so they'll be separate bullet points
    StringBuilder desc = new StringBuilder();
    for(int j=0; j<descriptions.length; j++) {
      desc.append(descriptions[j]);
      if (descriptions[j].length() > 0 && j < descriptions.length) {
        // don't apppend to the last one.
        desc.append('\r');
      }
    }
    r1.setText(desc.toString());

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
      pic.setAnchor(new java.awt.Rectangle(image.x, image.y, image.cx, image.cy));
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

}
