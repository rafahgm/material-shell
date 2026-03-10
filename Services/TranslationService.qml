pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

import qs.Common

Singleton {
    id: root

    property var translations: ({})
    property var availableLanguages: ["pt_BR"]
    property var availableGeneratedLanguages: []
    property bool isScanning: scanLanguagesProcess.running
    property bool isLoading: false
    property string translationKeepSuffix: "/*keep*/"
    property string translationsDir: Quickshell.shellPath("Translations")

    property string languageCode: {
        var configLang = Config?.options.language.ui ?? "auto";

        if (configLang !== "auto")
            return configLang;

        return Qt.locale().name;
    }

    TranslationScanner {
        id: scanLanguagesProcess
        translationsDir: root.translationsDir
        onLanguagesScanned: (languages) => {
            root.availableLanguages = [...languages];
        }
    }

    onLanguageCodeChanged: {
        console.info("[TranslationService] Language changed to", root.languageCode);
        translationFileView.languageCode = root.languageCode;
        translationFileView.reread();
    }

    TranslationReader {
        id: translationFileView
        translationsDir: root.translationsDir
        languageCode: root.languageCode
        onContentLoaded: (data) => {
            root.translations = data;
            root.isLoading = false;
        }
    }

    function tr(text) {
        // Special cases
        if (!text) return "";
        var key = text.toString();
        if (root.isLoading || !root?.translations?.hasOwnProperty(key))
            return key;
        
        // Normal cases
        var translation = root.translations[key] || key;
        // print(key, "-> [", root.translations[key], root.generatedTranslations[key], key, "] ->", translation);
        if (translation.endsWith(root.translationKeepSuffix)) {
            translation = translation.substring(0, translation.length - root.translationKeepSuffix.length).trim();
        }
        return translation;
    }

    component TranslationScanner: Process {
        id: translationScanner
        required property string translationsDir
        signal languagesScanned(var languages)

        command: ["find", translationScanner.translationsDir, "-name", "*.json", "-exec", "basename", "{}", ".json", ";"]
        running: true

        stdout: StdioCollector {
            id: languagesCollector
            onStreamFinished: {
                const output = languagesCollector.text;
                const files = output.trim().split('\n').map(f => f.trim());
                translationScanner.languagesScanned(files);
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                translationScanner.languagesScanned(["pt_BR"]);
            }
        }
    }

    component TranslationReader: FileView {
        id: translationReader
        required property string translationsDir
        property string languageCode: root.languageCode
        signal contentLoaded(var data)

        function reread() { // Proper reload in case the file was incorrect before
            translationReader.path = "";
            translationReader.path = `${translationReader.translationsDir}/${translationReader.languageCode}.json`;
            translationReader.reload();
        }
        path: ""

        onLoaded: {
            var textContent = "";
            try {
                textContent = text();
                var jsonData = JSON.parse(textContent);
                translationReader.contentLoaded(jsonData);
            } catch (e) {
                console.error("[TranslationService] Failed to load translations:", e);
                translationReader.contentLoaded({});
            }
        }
        onLoadFailed: error => {
            translationReader.contentLoaded({});
        }
    }
}