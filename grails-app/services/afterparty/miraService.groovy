package afterparty

class miraService {

    static transactional = false

    def sessionFactory

    def cleanUpGorm() {
        def session = sessionFactory.currentSession
        session.flush()
        session.clear()
    }

    Assembly createAssemblyAndContigsFromMiraInfo(File miraInfoFile, File aceFile, CompoundSample s) {

        def added = 0
        def startTime = System.currentTimeMillis()

        // open up the assembly info file and create an Assembly to hold it
        Assembly a = new Assembly(description: miraInfoFile.text, name: "assembly from ${miraInfoFile.name} ")
        // attach the assembly to the appropriate study
        s.addToAssemblies(a)
        a.save(flush: true)
        println "created assembly"



        def currentContigName
        def id2Start = [:]

        boolean inReadString = false
        boolean inContigString = false
        boolean inQualityString = false

        ArrayList currentReadString = []
        ArrayList currentContigString = []
        ArrayList currentQualityString = []

        def currentReadId

        def currentContig


        def session = sessionFactory.openStatelessSession()

        aceFile.eachLine { line ->

            if (line.startsWith(/CO /)) {
                if (currentContig) {
                    a.addToContigs(currentContig)
                    session.insert(currentContig)
//                    println "savid ${currentContig.name}"
                    if (++added % 100 == 0) {
                        println added
                    }
//                    println "${System.currentTimeMillis() - startTime}  :  $added"
                    // current best :  141155 after inserting 100
                    //                  80707 by switching to explicit setting of properties rather than using maps
                    //                  80926 by switching to saving contig rather than assembly
                    //                  25809 by switching to stateless session

                }
                currentContigString = []
                currentContigName = line.split(/ /)[1]
                println currentContigName
                inContigString = true

                currentContig = new Contig()
                currentContig.name = currentContigName
                currentContig.searchAssemblyId = a.id
            }

            else if (line.startsWith(/BQ/)) {
                inQualityString = true
            }

            else if (line.startsWith(/AF /)) {
                id2Start.put(line.split(/ /)[1], line.split(/ /)[3].toInteger())
            }

            else if (line.startsWith(/RD /)) {
                currentReadId = line.split(/ /)[1]
                inReadString = true
            }

            else if (line.equals('') && inReadString) {    // we have reached the end of the read sequence string
                Integer start = id2Start.get(currentReadId).toInteger()
                StringBuilder outputString = new StringBuilder()
                ArrayList alignedReadString = []

                Integer deletedBases = 0

                if (start > 0) {
                    alignedReadString = ['-'].multiply(start - 1) + currentReadString
                }
                else {
                    ((1 - start)..currentReadString.size()).each {
                        alignedReadString.add(currentReadString[it])
                    }
                }
                alignedReadString.eachWithIndex {base, i ->
                    def contigBase = currentContigString[i]
                    if (currentContigString.size() > i && contigBase == '*') {
                        outputString.append("")
                        deletedBases++
                    }
                    else {
                        outputString.append(base)
                    }
                }

                def r = new Read()
                r.name = currentReadId
                r.start = start
                r.sequence = outputString.toString()
                r.stop = start + currentReadString.size() - deletedBases
                currentContig.addToReads(r)
                session.insert(r)
                currentReadString = []
                inReadString = false;
            }

            else if (line.equals('') && inContigString) {    // we have reached the end of the contig sequence string
                currentContig.sequence = currentContigString.join('').replaceAll(/\*/, '')
                inContigString = false;
            }

            else if (line.equals('') && inQualityString) {    // we have reached the end of the contig sequence string
                //        currentFile.append(currentQualityString.join('') + "\n")
                currentContig.quality = currentQualityString.join(' ')
                currentQualityString = []
                inQualityString = false;
            }

            else if (inReadString) {
                currentReadString.addAll(line.split('').findAll({it != ''}))
            }

            else if (inContigString) {
                currentContigString.addAll(line.split('').findAll({it != ''}))
            }
            else if (inQualityString) {
                currentQualityString.addAll(line.split(' ').findAll({it != ''}))
            }

        }
        if (currentContig) {
            a.addToContigs(currentContig)
            session.insert(currentContig)

        }

//        println "saving contigs"
        a = a.merge()
        a.save(flush: true)
//        println "saved all contigs"
        // we will not bother indexing - there is nothing interesting here anyway
        //        println "indexing...."
        //        allContigs.each{
        //            Contig c = (Contig) it
        ////            c.index()
        //        }
        //        println "finished indexing"
        return a

    }



    def runMira(def readsFileIds, def jobId, def compoundSampleId) {

        println " ${new Date()} running mira on reads file with id $readsFileIds"

        // update the job to show that it's running
        BackgroundJob job = BackgroundJob.get(jobId)
        job.progress = "running mira"
        job.status = BackgroundJobStatus.RUNNING
        job.save(flush: true)

        // generate a uuid for the project and create an input file
        String projectName = UUID.randomUUID().toString()
        File procInput = new File("/tmp/${projectName}_in.454.fastq")
        procInput.delete()

        // write the reads to the input file
        readsFileIds.each { readsFileId ->
            ReadsFile readsFile = ReadsFile.get(readsFileId)
            println "reads file is $readsFile"
            println "run of reads file is " + readsFile.run
            def readData = readsFile.data.fileData
            procInput.append(readData)
        }

        // construct the mira command line, set the working directory to /tmp, and start the process
        println "starting process"
        def p = new ProcessBuilder("/home/martin/Downloads/mira_3.2.1_prod_linux-gnu_x86_64_static/bin/mira --job=denovo,est,draft,454 --project=${projectName} -DI:lrt=/tmp -GE:not=4 454_SETTINGS -LR:lsd=yes:ft=fastq -notraceinfo".split(" "))
        job.commandLine = p.command().join('')
        p.directory(new File("/tmp"))
        p.redirectErrorStream(true)
        p = p.start()

        // monitor stdout of the mira process and update the job to show which pass we are on
        p.in.eachLine({
            if (it.contains('Pass')) {
                job.progress = it
                job.save(flush: true)
            }
        })

        File assemblyInfoFile = new File("/tmp/${projectName}_assembly/${projectName}_d_info/${projectName}_info_assembly.txt")
        File contigsFile = new File("/tmp/${projectName}_assembly/${projectName}_d_results/${projectName}_out.padded.fasta")
        File contigsQualityFile = new File("/tmp/${projectName}_assembly/${projectName}_d_results/${projectName}_out.padded.fasta.qual")
        File contigsStatsFile = new File("/tmp/${projectName}_assembly/${projectName}_d_info/${projectName}_info_contigstats.txt")

        CompoundSample s = CompoundSample.get(compoundSampleId)

        Assembly a = createAssemblyAndContigsFromMiraInfo(assemblyInfoFile, contigsFile, contigsQualityFile, contigsStatsFile, s)

        // update the job to show that we're finished and set the sink and source ids
        job.progress = 'finished'
        job.status = BackgroundJobStatus.FINISHED
        readsFileIds.each { readsFileId ->
            job.addToSources(readsFileId.toLong())
        }
        job.addToSinks(a.id)
        job.label = 'mira'
        job.save(flush: true)


    }

    Map parseFasta(InputStream contigsFile) {
        Map name2seq = [:]
        StringBuffer seq = new StringBuffer('')
        String name = ""
        contigsFile.eachLine { line ->
            if (line.startsWith('>')) {
                if (name) {
                    name2seq.put(name, seq.toString())
                }
                name = line.substring(1)
                seq = new StringBuffer()
            }
            else {
                seq.append(line)
            }
        }
        name2seq.put(name, seq.toString())
        return name2seq
    }
}
