package afterparty

class Assembly {

    def statisticsService

    String description
    String name

    ContigSet defaultContigSet

    static hasMany = [contigs: Contig]

//    static fetchMode = [contigs: "eager"]

    static constraints = {
        defaultContigSet(nullable: true)
    }


    static mapping = {
        description type: 'text'
        name type: 'text'
        contigs cascade: "all-delete-orphan"

    }

    static belongsTo = [compoundSample: CompoundSample]

    def getContigCount() {
        return contigs ? statisticsService.getAssemblyStats(this.id.toLong()).readCount : 0
    }

    def getMeanContigLength() {
        return contigs ? statisticsService.getAssemblyStats(this.id.toLong()).meanLength : 0
    }

    def getMaxContigLength() {
        return contigs ? statisticsService.getAssemblyStats(this.id.toLong()).maxLength : 0
    }

    def getMinContigLength() {
        return contigs ? statisticsService.getAssemblyStats(this.id.toLong()).minLength : 0
    }

    def getBaseCount() {
        return contigs ? statisticsService.getAssemblyStats(this.id.toLong()).baseCount : 0
    }

    def getN50() {
        return contigs ? statisticsService.getAssemblyStats(this.id.toLong()).n50 : 0
    }


    def isPublished(){
        return this.compoundSample.isPublished()
    }

    def isOwnedBy(def user){
         return this.compoundSample.isOwnedBy(user)
    }
}
