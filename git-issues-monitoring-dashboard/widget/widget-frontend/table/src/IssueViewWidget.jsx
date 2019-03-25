/*
 *  Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 *  WSO2 Inc. licenses this file to you under the Apache License,
 *  Version 2.0 (the "License"); you may not use this file except
 *  in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing,
 *  software distributed under the License is distributed on an
 *  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 *  KIND, either express or implied.  See the License for the
 *  specific language governing permissions and limitations
 *  under the License.
 *
 */

/* eslint-disable react/prop-types, react/jsx-handler-names */

import React from 'react';
import Widget from '@wso2-dashboards/widget';
import ReactTable from 'react-table';
import './resources/css/react-table.css';
import {createMuiTheme, MuiThemeProvider, withStyles} from '@material-ui/core/styles';
import TextField from '@material-ui/core/TextField';
import Paper from '@material-ui/core/Paper';
import Chip from '@material-ui/core/Chip';
import MenuItem from '@material-ui/core/MenuItem';
import Select from 'react-select';
import Typography from '@material-ui/core/Typography';
import {emphasize} from '@material-ui/core/styles/colorManipulator';
import PropTypes, { func } from 'prop-types';
import classNames from 'classnames';
import Button from '@material-ui/core/Button';
import axios from 'axios';
import { MapsTransferWithinAStation } from 'material-ui/svg-icons';
import transferWithinAStation from 'material-ui/svg-icons/maps/transfer-within-a-station';
import _ from 'lodash'

let suggestions = [
    {label: 'Severity/Blocker'},
    {label: 'Severity/Critical'},
    {label: 'Severity/Major'},
    {label: 'Severity/Minor'},
    {label: 'Priority/High'},
    {label: 'Priority/Highest'},
    {label: 'Priority/Low'},
    {label: 'Priority/Normal'},
    {label: 'Resolution/Cannot Reproduce'},
    {label: 'Resolution/Duplicate'},
    {label: 'Resolution/Fixed'},
    {label: 'Resolution/Invalid'},
    {label: 'Resolution/Not a bug'},
    {label: 'Resolution/Postponed'},
    {label: 'Resolution/Won\'t Fix'},
    {label: 'Type/Bug'},
    {label: 'Type/Documentation'},
    {label: 'Type/Epic'},
    {label: 'Type/Improvement'},
    {label: 'Type/New Feature'},
    {label: 'Type/Question'},
    {label: 'Type/Task'},
    {label: 'Type/UX'},
].map(suggestion => ({
    value: suggestion.label,
    label: suggestion.label,
}));

let productSuggestions = [].map(productSuggestions => ({
    value: productSuggestions.label,
    label: productSuggestions.label,
}));

let repoSuggestions = [].map(repoSuggestions => ({
    value: repoSuggestions.label,
    label: repoSuggestions.label,
}));


const styles = theme => ({
    root: {
        paddingBottom: '70px'
    },
    input: {
        display: 'flex',
        padding: 0,
    },
    valueContainer: {
        display: 'flex',
        flexWrap: 'wrap',
        flex: 1,
        alignItems: 'center',
    },
    chip: {
        margin: `${theme.spacing.unit / 2}px ${theme.spacing.unit / 4}px`,
    },
    chipFocused: {
        backgroundColor: emphasize(
            theme.palette.type === 'light' ? theme.palette.grey[300] : theme.palette.grey[700],
            0.08,
        ),
    },
    noOptionsMessage: {
        padding: `${theme.spacing.unit}px ${theme.spacing.unit * 2}px`,
    },
    singleValue: {
        fontSize: 16,
    },
    placeholder: {
        position: 'absolute',
        left: 2,
        fontSize: 16,
        color: '#f9f9f9'
    },
    paper: {
        position: 'absolute',
        zIndex: 1,
        marginTop: theme.spacing.unit,
        left: 0,
        right: 0,
    },
    divider: {
        height: theme.spacing.unit * 2,
    },
});

function NoOptionsMessage(props) {
    return (
        <Typography
            color="textSecondary"
            className={props.selectProps.classes.noOptionsMessage}
            {...props.innerProps}
        >
            {props.children}
        </Typography>
    );
}

function inputComponent({inputRef, ...props}) {
    return <div ref={inputRef} {...props} />;
}

function Control(props) {
    return (
        <TextField
            fullWidth
            InputProps={{
                inputComponent,
                inputProps: {
                    className: props.selectProps.classes.input,
                    inputRef: props.innerRef,
                    children: props.children,
                    ...props.innerProps,
                },
            }}
            {...props.selectProps.textFieldProps}
        />
    );
}

function Option(props) {
    return (
        <MenuItem
            buttonRef={props.innerRef}
            selected={props.isFocused}
            component="div"
            style={{
                fontWeight: props.isSelected ? 500 : 400,
            }}
            {...props.innerProps}
        >
            {props.children}
        </MenuItem>
    );
}

function Placeholder(props) {
    return (
        <Typography
            color="textSecondary"
            className={props.selectProps.classes.placeholder}
            {...props.innerProps}
        >
            {props.children}
        </Typography>
    );
}

function SingleValue(props) {
    return (
        <Typography className={props.selectProps.classes.singleValue} {...props.innerProps}>
            {props.children}
        </Typography>
    );
}

function ValueContainer(props) {
    return <div className={props.selectProps.classes.valueContainer}>{props.children}</div>;
}

function MultiValue(props) {
    return (
        <Chip
            tabIndex={-1}
            label={props.children}
            className={classNames(props.selectProps.classes.chip, {
                [props.selectProps.classes.chipFocused]: props.isFocused,
            })}
            onDelete={event => {
                props.removeProps.onClick();
                props.removeProps.onMouseDown(event);
            }}
        />
    );
}

function Menu(props) {
    return (
        <Paper square className={props.selectProps.classes.paper} {...props.innerProps}>
            {props.children}
        </Paper>
    );
}

const components = {
    Option,
    Control,
    NoOptionsMessage,
    Placeholder,
    SingleValue,
    MultiValue,
    ValueContainer,
    Menu,
};


/**
 * Issue View Widget
 * */

class IssueViewWidget extends Widget {
    /**
     * Constructor.
     */
    constructor(props) {
        console.log("Constructor called");
        super(props);
        this.state = {
            id: props.id,
            repo_name: null,
            labels: null,
            labelOptions: ['critical', 'Major', 'minor'],
            selectedLabels: [],
            page: 0,
            product: null,
            data:[],
            productSuggestionsArray:[],
            repoSuggestionsArray:[],
            arrangedData:[],
            loading: false
        };

        this.tableColumns = [{
            Header: 'Git Repo Name',
            accessor: 'repositoryName',
            Cell: this.getNormalCellComponent,
            Filter: props => {
                return (
                    <input
                        style={{width: "70%", backgroundColor:"#132630", color:"#ffffff"}}
                        placeholder='Search for Repo Name..'
                        onChange={event => {
                            this.setState({
                                repoFilterValue: event.target.value
                            });
                            props.onChange(event.target.value);
                        }}
                        value={this.state.repoFilterValue || ''}
                    />
                );
            },
            filterMethod: (filter, row) => {
                const id = filter.pivotId || filter.id;
                var record = row[id];
                if(record instanceof Array){
                    var status = false;
                    record.forEach(rec =>{
                        if(String(rec.props.children.props.children).toLowerCase().includes(filter.value)){
                            status = true;
                        }
                    });
                    return status;
                }
                console.log("return Value"+ String(row[id]).toLowerCase().includes(filter.value));
                return row[id] !== undefined ? String(row[id]).toLowerCase().includes(filter.value) : true
            },
            style: {'whiteSpace': 'unset', paddingLeft: '15px',flex:"20 0 auto !important"},
        }, {
            Header: 'Issues title',
            id: "issueTitleWitheURL",
            accessor: d => d.issueTitleWitheURL,
            Cell: this.getNormalCellComponent,
            Filter: props => {
                return (
                    <input
                        style={{width: "70%", backgroundColor:"#132630", color:"#ffffff"}}
                        placeholder='Search for Issue Title.. '
                        onChange={event => {
                            this.setState({
                                issueFilterValue: event.target.value
                            });
                            props.onChange(event.target.value);
                        }}
                        value={this.state.issueFilterValue || ''}
                    />
                );
            },
            filterMethod: (filter, row) => {
                const id = filter.pivotId || filter.id;
                var record = row[id];
                if(record instanceof Array){
                    var status = false;
                    record.forEach(rec =>{
                        if(String(rec.props.children).toLowerCase().includes(filter.value.toLowerCase())){
                            status = true;
                        }
                    });
                    return status;
                }
                console.log("return Value"+ String(row[id]).toLowerCase().includes(filter.value));
                return row[id] !== undefined ? String(row[id]).toLowerCase().includes(filter.value) : true
            },
            style: {'whiteSpace': 'unset', paddingLeft: '15px', flex:"100 0 50 !important"},
        }, {
            Header: 'Issue Labels',
            id:"issueLabels",
            accessor: d => d.labels,
            Cell: this.getNormalCellComponent,
            Filter: props => {
                return (
                    <input
                        style={{width: "70%",backgroundColor:"#132630", color:"#ffffff"}}
                        placeholder='Search for Label..'
                        onChange={event => {
                            this.setState({
                                labelFilterValue: event.target.value
                            });
                            props.onChange(event.target.value);
                        }}
                        value={this.state.labelFilterValue || ""}
                    />
                );
            },
            filterMethod: (filter, row) => {
                const id = filter.pivotId || filter.id;
                var record = row[id];
                if(record instanceof Array){
                    var status = false;
                    record.forEach(rec =>{
                        if(String(rec.props.children.props.children).toLowerCase().includes(filter.value)){
                            status = true;
                        }
                    });
                    return status;
                }
                console.log("return Value"+ String(row[id]).toLowerCase().includes(filter.value));
                return row[id] !== undefined ? String(row[id]).toLowerCase().includes(filter.value) : true
            },
            style: { flex:"50 0 auto !important", flexWrap:"wrap"},


        }];

        const components = {
            Option,
        };

        this.handleChange = this.handleChange.bind(this);
        this.handleRepositoryChange = this.handleRepositoryChange.bind(this);
        this.handleClick = this.handleClick.bind(this);
        this.handleProductChange = this.handleProductChange.bind(this);
        this.disableButton = this.disableButton.bind(this);
        this.onFiltersChange = this.onFiltersChange.bind(this);

    };

    handleChange(value){
        this.setState({
            labels : value,
        }, () => {
            console.log(this.state.labels);
        });
    };

    handleRepositoryChange(value) {
        this.setState({
            repo_name: value,
        },()=> {
            console.log(this.state.repo_name);
        });
    };

    onFiltersChange(value){
        console.log(value);
    }
    handleProductChange(value){
        if(value != null){
            axios.create({
                withCredentials: false,
            }).get("https://"+window.location.host+window.contextPath+"/apis/gitIssues/repos/"+value.value
            ).then(res=>{
                var i = 0;
                repoSuggestions = [];
                res.data.forEach(repo => {
                    var labelObject = {};
                    labelObject.label = repo;
                    repoSuggestions[i] = labelObject;
                    i = i + 1;
                });
                this.setState({
                    repoSuggestionsArray : repoSuggestions.map(repoSuggestions => ({
                        value: repoSuggestions.label,
                        label: repoSuggestions.label,
                    })),
                });

            });
        }else {
            axios.create({
                withCredentials: false,
            }).get("https://"+window.location.host+window.contextPath+"/apis/gitIssues/repos/all"
            ).then(res=>{
                var i = 0;
                repoSuggestions = [];
                res.data.forEach(repo => {
                    var labelObject = {};
                    labelObject.label = repo;
                    repoSuggestions[i] = labelObject;
                    i = i + 1;
                });
                this.setState({
                    repoSuggestionsArray : repoSuggestions.map(repoSuggestions => ({
                        value: repoSuggestions.label,
                        label: repoSuggestions.label,
                    })),
                });

            });
        }
        this.setState({
            product : value,
        },() =>{
            console.log(this.state.product);
        });
    };

    renderPreLoader = () => {
        return (
            <div className={"outer-div"}>
                <div className={"center-div"}>
                    <div className={"inner-div"}>
                        <div>
                            <h2>Loading Data....</h2>
                            <div className={"psoload"}>
                                <div className={"straight"} />
                                <div className={"curve"} />
                                <div className={"center"} />
                                <div className={"inner"} />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        );
    };

    handleClick(){
        this.setState({
            data : [],
            loading: true
        },() =>{
            console.log(this.state.data);
        });
        const labelArray = [];
        const repoArray = [];
        if(this.state.repo_name !=null){
            if (this.state.labels != null ){
                this.state.labels.forEach(element => {
                    labelArray.push(element.value);
                });
            }
            this.state.repo_name.forEach(element => {
                repoArray.push(element.value);
            });
            axios.create({
                withCredentials: false,
            }).get("https://"+window.location.host+window.contextPath+"/apis/gitIssues/",{
                params : {
                    "labels":JSON.stringify(labelArray),
                    "repos" : JSON.stringify(repoArray),
                }
            }).then(res => {
                var response =  res.data;
                var tempArray =[];
                response.forEach(
                    rec => {
                        console.log(rec);
                        rec.issues.forEach(issue =>{ tempArray.push(issue)});
                    });
                this.setState({
                    data: tempArray,
                    loading: false
                });
            })
        }else if(this.state.product != null && this.state.repo_name ==null){
            if (this.state.labels != null ){
                this.state.labels.forEach(element => {
                    labelArray.push(element.value);
                });
            }
            axios.create({withCredentials:false,}).get(
                "https://"+window.location.host+window.contextPath+"/apis/gitIssues/product/"+this.state.product.value,{
                    params:{
                        "labels": JSON.stringify(labelArray)
                    }
                }).then(
                res =>{
                    console.log(res.data);
                    var response =  res.data;
                    var tempArray =[];
                    response.forEach(
                        rec => {
                            console.log(rec);
                            if(rec.issues.length >0 ){
                                rec.issues.forEach(issue =>{ tempArray.push(issue)});
                            }
                        });
                    this.setState({
                        data: tempArray,
                        loading: false
                    });
                }
            )
        }
    };



    componentDidMount() {
        if(productSuggestions.length==0){
            axios.create({
                withCredentials: false,
            }).get("https://"+window.location.host+window.contextPath+"/apis/gitIssues/products"
            ).then(res=>{
                var i = 0;
                productSuggestions = [];
                res.data.forEach(repo => {
                    var labelObject = {};
                    labelObject.label = repo;
                    productSuggestions[i] = labelObject;
                    i = i + 1;
                });
                this.setState({
                    productSuggestionsArray : productSuggestions.map(productSuggestions => ({
                        value: productSuggestions.label,
                        label: productSuggestions.label,
                    })),
                });

            });
        }
        if(this.state.product==null){
            axios.create({
                withCredentials: false,
            }).get("https://"+window.location.host+window.contextPath+"/apis/gitIssues/repos/all"
            ).then(res=>{
                var i = 0;
                repoSuggestions = [];
                res.data.forEach(repo => {
                    var labelObject = {};
                    labelObject.label = repo;
                    repoSuggestions[i] = labelObject;
                    i = i + 1;
                });
                this.setState({
                    repoSuggestionsArray : repoSuggestions.map(repoSuggestions => ({
                        value: repoSuggestions.label,
                        label: repoSuggestions.label,
                    })),
                });

            });
        }
    }

    renderProductSearchDropDown(classes, selectStyles, repoSuggestions, components) {
        return (
            <div style={{width: '25%', paddingRight: '30px'}}>
                <Select
                    classes={classes}
                    styles={selectStyles}
                    textFieldProps={{
                        label: 'Product Name',
                        InputLabelProps: {
                            shrink: true,
                        },
                    }}
                    options={this.state.productSuggestionsArray}
                    components={components}
                    value={this.state.product}
                    onChange={this.handleProductChange}
                    placeholder="Search for a Product"
                    isClearable
                />
            </div>
        )
    }

    renderLabelMultiSelect(classes , selectStyles, suggestions,components) {
        return (
            <div style={{width: '25%', paddingRight: '30px'}}>
                <Select
                    classes={classes}
                    styles={selectStyles}
                    textFieldProps={{
                        label: 'Label',
                        InputLabelProps: {
                            shrink: true,
                        },
                    }}
                    options={suggestions}
                    components={components}
                    value={this.state.labels}
                    onChange={this.handleChange}
                    placeholder="Select multiple labels"
                    isMulti
                />
            </div>)
    }

    renderRepoMultiSelect(classes , selectStyles, repoSuggestions, components) {
        return (
            <div style={{width: '25%', paddingRight: '30px'}}>
                <Select
                    classes={classes}
                    styles={selectStyles}
                    textFieldProps={{
                        label: 'Repo Name',
                        InputLabelProps: {
                            shrink: true,
                        },
                    }}
                    options={this.state.repoSuggestionsArray}
                    components={components}
                    value={this.state.repo_name}
                    onChange={this.handleRepositoryChange}
                    placeholder="Select Multiple Repositories"
                    isMulti
                />
            </div>)
    }

    disableButton(){
        if(repo_name ==""  || product =="" ){
            return true
        }else{
            return false
        }
    }

    renderTable(){
        return(
            <ReactTable
                className={this.props.muiTheme.name === 'light' ? 'lightTheme' : 'darkTheme'}
                data={this.state.data}
                columns={this.tableColumns}
                style={{ width: "100%" }}
                filterable
            />
        );
    }

    render() {
        const {classes, theme} = this.props;
        let {data} = this.state;

        const selectStyles = {
            input: base => ({
                ...base,
                color: theme.palette.text.primary,
            }),
        };

        let reactTheme = createMuiTheme({
            palette: {
                type: this.props.muiTheme.name,
            },
            typography: {
                useNextVariants: true,
            },
        });

        return (
            data.forEach(d => {
                d.labels = [];
                d.issueTitleWitheURL = [];
                d.issueLabels.forEach(l => {
                    if(l.startsWith("Severity")){
                        d.labels.push(<span style={{flexBasis:'100%',paddingLeft:"12px"}}><span id='issue-severity' >{l}</span></span> );
                    }else if(l.startsWith("Type")){
                        d.labels.push(<span style={{flexBasis:'100%',paddingLeft:"12px"}}><span id='issue-type' >{l}</span></span>);
                    }else if(l.startsWith("Resolution")){
                        d.labels.push(<span style={{flexBasis:'100%',paddingLeft:"12px"}}><span id='issue-resolution' >{l}</span></span>);
                    }else if(l.startsWith("Priority")){
                        d.labels.push(<span style={{flexBasis:'100%',paddingLeft:"12px"}}><span id='issue-priority'>{l}</span></span>);
                    }else{
                        d.labels.push(<span style={{flexBasis:'100%',paddingLeft:"12px"}}><span id='issue-other'>{l}</span></span>);
                    }
                })
                d.issueTitleWitheURL.push(<a href={d.url} target="_blank">{d.issueTitle}</a>)

            }),

                <MuiThemeProvider theme={reactTheme}>
                    <div style={{margin: '1% 2% 0 2%'}}>
                        <div style={{display: 'flex', flexWrap: 'wrap', justifyContent: 'flex-end', marginBottom: '30px'}}>
                            {this.renderProductSearchDropDown(classes , selectStyles, productSuggestions, components)}
                            {this.renderRepoMultiSelect(classes,selectStyles,repoSuggestions,components)}
                            {this.renderLabelMultiSelect(classes , selectStyles, suggestions, components)}
                            <div style={{paddingTop: '15px'}}>
                                <Button variant="contained" className={classes.button} color="primary" onClick={this.handleClick}>Search</Button>
                            </div>
                        </div>
                        <div style={{clear: 'both'}}>
                            {this.state.loading ? this.renderPreLoader() : this.renderTable()}
                        </div>
                    </div>
                </MuiThemeProvider>
        );
    }
}

IssueViewWidget.propTypes = {
    classes: PropTypes.object.isRequired,
    theme: PropTypes.object.isRequired,
};

global.dashboard.registerWidget("IssueViewWidget", withStyles(styles, {withTheme: true})(IssueViewWidget));
