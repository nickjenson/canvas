'use strict';

const main = () => {
    if (window.location.pathname.match(/\/courses\/(\d+)\/settings*/)) {
        const course_id = document.getElementById('course_sis_source_id')?.value;
        const sections = document.querySelectorAll('#sections > li.section > a');
        courseDetails(course_id);
        sectionDetails(sections);
    }
};

// parse API response for sis_import_id
const getJSON = async url => {
    const text = (await (await fetch(url)).text()).replace('while(1);', '');
    const sis_import = JSON.parse(text)?.sis_import_id;
    return !sis_import ? '' : sis_import;
};

// handle course_id in courses/:id/settings
const courseDetails = async course_id => {
    if (course_id) {
        const sis_id = await getJSON(`/api/v1/courses/sis_course_id:${course_id}`);
        const query = document.querySelector('#tab-details > h2');
        pageExtra(query, sis_id);
    }
};

// handle each section in courses/:id/settings
const sectionDetails = sections => {
    if (sections) {
        sections.forEach(async (section, index) => {
            const href = section.getAttribute('href').split('/');
            const sis_id = await getJSON(`/api/v1/sections/${href[href.length - 1]}`);
            const query = document.querySelector(`#sections > .section:nth-child(${index + 1}) > span.section_links`);
            pageExtra(query, sis_id);
        });
    }
};

// add new element with sis_import_id information if applicable
const pageExtra = (query, sis_id) => {
    if (sis_id != '') {
        const small = document.createElement('small');
        small.innerHTML = `Last touched by SIS Import: <a href='/api/v1/accounts/self/sis_imports/${sis_id}'>${sis_id}</a>`;
        query.after(small);
    }
};

main();
