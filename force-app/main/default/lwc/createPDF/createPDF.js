import { LightningElement, api } from 'lwc';
import pdflib from '@salesforce/resourceUrl/pdflib';
import {loadScript} from 'lightning/platformResourceLoader';

export default class CreatePDF extends LightningElement {
    @api files;

    renderedCallback(){
        loadScript(this, pdflib).then();
    }

    // async createPdf() {
    //     const pdfDoc = await PDFLib.PDFDocument.create()
    //     const timesRomanFont = await pdfDoc.embedFont(PDFLib.StandardFonts.TimesRoman)
      
    //     const page = pdfDoc.addPage()
    //     const { width, height } = page.getSize()
    //     const fontSize = 30
    //     page.drawText('Creating PDFs in JavaScript is awesome!', { 
    //       x: 50,
    //       y: height - 4 * fontSize,
    //       size: fontSize,
    //       font: timesRomanFont,
    //       color: PDFLib.rgb(0, 0.53, 0.71),
    //     })
      
    //     const pdfBytes = await pdfDoc.save()
    //     this.saveByteArray("Notes", pdfBytes)
    // }

    createTable(files, timesRomanFont) {
        let table = '';
        files.forEach((row) => {
            let rowFile = '';
            rowFile += `Title: ${row.title}\n`;
            rowFile += `Body: ${row.body}\n`;
            rowFile += `Owner Name: ${row.ownerName}\n`;
            // format date to DD/MM/YYYY
            let date = new Date(row.CreatedDate);
            let formattedDate = `${date.getDate()}/${date.getMonth()+1}/${date.getFullYear()}`;
            rowFile += `Created Date: ${formattedDate}\n`;
            rowFile += `User Name: ${row.UserName}\n`;
            table += `${rowFile}\n`;
        });
        return table;
    }

    async createPdf() {
        // replace this with the actual data source
        const pdfDoc = await PDFLib.PDFDocument.create()
        const timesRomanFont = await pdfDoc.embedFont(PDFLib.StandardFonts.TimesRoman)
      
        const page = pdfDoc.addPage()
        const { width, height } = page.getSize()
        const fontSize = 12

        let table = this.createTable(this.files, timesRomanFont);
        page.drawText(table, { 
            x: 50,
            y: height - 4 * fontSize,
            size: fontSize,
            font: timesRomanFont,
            color: PDFLib.rgb(0, 0.53, 0.71),
        })
      
        const pdfBytes = await pdfDoc.save()
        this.saveByteArray("Notes", pdfBytes)
    }


    saveByteArray(pdfName, byte) {
        var blob = new Blob([byte], {type:"application/pdf"});
        var link = document.createElement("a");
        link.href = window.URL.createObjectURL(blob);
        var fileName = pdfName;
        link.download = fileName;
        link.click();
    }
}