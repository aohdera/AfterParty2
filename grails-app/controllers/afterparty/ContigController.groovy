package afterparty

import org.compass.core.engine.SearchEngineQueryParseException

class ContigController {

    static allowedMethods = [save: "POST", update: "POST", delete: "POST"]

    def searchableService
    def contigAnnotationService

    def index = {
        redirect(action: "list", params: params)
    }



    def show = {
        def contigInstance = Contig.get(params.id)
        if (!contigInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'contig.label', default: 'Contig'), params.id])}"
            redirect(action: "list")
        }
        else {
            [contigInstance: contigInstance]
        }
    }


    def showJSON = {
        def contigInstance = Contig.get(params.id)
        render(contentType: "text/json") {
            length = contigInstance.length()
            quality = contigInstance.quality.split(' ')
            blastHits = contigInstance.blastHits.sort({-it.bitscore})
            reads = contigInstance.reads.sort({it.start})   // sort the reads by start position so they pile up nicely
        }
    }

}


