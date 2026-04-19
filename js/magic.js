function importfile() {
    let file = document.getElementById("fileimport");
    if (!confirm("Are you sure you want to import?")) return;
    let source = document.getElementById("source");
    file.files[0].text().then((value) => source.value = value);
}
function testit() {
    let testwindow = window.open("");
    with (testwindow.document) {
        writeln(document.getElementById("source").value);
    }
}
function downloadit() {
    let name = document.getElementById("filename").value;
    let extension = name.substring(name.search(/\..*/),name.length);
    let file = new Blob([document.getElementById("source").value], {type: extension});
    if (window.navigator.msSaveOrOpenBlob)
        window.navigator.msSaveOrOpenBlob(file, name)
    else {
        let a = document.createElement("a"),
            url = URL.createObjectURL(file);
        a.href = url;
        a.download = name;
        document.body.appendChild(a);
        a.click();
        setTimeout(function() {
            document.body.removeChild(a);
            window.URL.revokeObjectURL(url);  
        }, 0); 
    }
}
function handleKeyDown(e) {
    if (e.key === "Tab") {
        e.preventDefault();
        const start = this.selectionStart;
        const end = this.selectionEnd;
        this.value =
            this.value.substring(0, start) + "\t" + this.value.substring(end);
        this.selectionStart = this.selectionEnd = start + 1;
    }
}
